;; Copyright 2020 the authors.
;; This file is part of Hy, which is free software licensed under the Expat
;; license. See the LICENSE.

(defn test-defclass []
  "NATIVE: test defclass simple mechanism"
  (defclass A)
  (assert (isinstance (A) A)))


(defn test-defclass-inheritance []
  "NATIVE: test defclass inheritance"
  (defclass A [])
  (assert (isinstance (A) object))
  (defclass A [object])
  (assert (isinstance (A) object))
  (defclass B [A])
  (assert (isinstance (B) A))
  (defclass C [object])
  (defclass D [B C])
  (assert (isinstance (D) A))
  (assert (isinstance (D) B))
  (assert (isinstance (D) C))
  (assert (not (isinstance (A) D))))


(defn test-defclass-attrs []
  "NATIVE: test defclass attributes"
  (defclass A []
    (setv x 42))
  (assert (= A.x 42))
  (assert (= (getattr (A) "x")  42)))


(defn test-defclass-attrs-fn []
  "NATIVE: test defclass attributes with fn"
  (defclass B []
    (setv x 42)
    (setv y (fn [self value]
      (+ self.x value))))
  (assert (= B.x 42))
  (assert (= (.y (B) 5) 47))
  (setv b (B))
  (setv B.x 0)
  (assert (= (.y b 1) 1)))


(defn test-defclass-dynamic-inheritance []
  "NATIVE: test defclass with dynamic inheritance"
  (defclass A [((fn [] (if True list dict)))]
    (setv x 42))
  (assert (isinstance (A) list))
  (defclass A [((fn [] (if False list dict)))]
    (setv x 42))
  (assert (isinstance (A) dict)))


(defn test-defclass-no-fn-leak []
  "NATIVE: test defclass attributes with fn"
  (defclass A []
    (setv x (fn [] 1)))
  (try
   (do
    (x)
    (assert False))
   (except [NameError])))

(defn test-defclass-docstring []
  "NATIVE: test defclass docstring"
  (defclass A []
    (setv --doc-- "doc string")
    (setv x 1))
  (setv a (A))
  (assert (= a.__doc__ "doc string"))
  (defclass B []
    "doc string"
    (setv x 1))
  (setv b (B))
  (assert (= b.x 1))
  (assert (= b.__doc__ "doc string"))
  (defclass MultiLine []
    "begin a very long multi-line string to make
     sure that it comes out the way we hope
     and can span 3 lines end."
    (setv x 1))
  (setv mL (MultiLine))
  (assert (= mL.x 1))
  (assert (in "begin" mL.__doc__))
  (assert (in "end" mL.__doc__)))

(defn test-defclass-macroexpand []
  "NATIVE: test defclass with macro expand"
  (defmacro M [] `(defn x [self x] (setv self._x x)))
  (defclass A [] (M))
  (setv a (A))
  (a.x 1)
  (assert (= a._x 1)))

(defn test-defclass-syntax []
  "NATIVE: test defclass syntax with properties and methods and side-effects"
  (setv foo 1)
  (defclass A []
    (setv x 1)
    (setv y 2)
    (global foo)
    (setv foo 2)
    (defn greet [self]
      "Greet the caller"

      "hello!"))
  (setv a (A))
  (assert (= a.x 1))
  (assert (= a.y 2))
  (assert foo 2)
  (assert (.greet a) "hello"))

(defn test-defclass-implicit-none-for-init []
  "NATIVE: test that defclass adds an implicit None to --init--"
  (defclass A []
    (setv --init-- (fn [self] (setv self.x 1) 42)))
  (defclass B []
    (defn --init-- [self]
      (setv self.x 2)
      42))

  (setv a (A))
  (setv b (B))
  (assert (= a.x 1))
  (assert (= b.x 2)))

(defn test-class-sideeffects []
  "NATIVE: test that defclass runs all expressions"
  (defn set-sentinel []
    (setv set-sentinel.set True))
  (setv set-sentinel.set False)

  (defclass A []
    (set-sentinel))

  (assert set-sentinel.set))
