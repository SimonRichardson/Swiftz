//
//  Reader.swift
//  Swiftz
//
//  Created by Matthew Purland on 11/25/15.
//  Copyright © 2015 TypeLift. All rights reserved.
//

import Foundation

/// A type for a `Reader` monad
public protocol ReaderType {
    /// The environment
    typealias Environment
    
    /// The modified environment
    typealias ModifiedEnvironment
    
    /// The function that modifies the environment
    var reader : Environment -> ModifiedEnvironment { get }
    
    /// Runs the reader and extracts the final value from it
    func runReader(environment : Environment) -> ModifiedEnvironment
    
    /// Executes a computation in a modified environment
    func local(f : Environment -> Environment) -> Self
}

/// A `Reader` monad.
public struct Reader<R, A> {
    private let f : R -> A
    
    init(_ reader : R -> A) {
        f = reader
    }
    
    public func mapReader<B>(f : A -> B) -> Reader<R, B> {
        return Reader<R, B>(f • runReader)
    }
}

extension Reader: ReaderType {
    public typealias Environment = R
    public typealias ModifiedEnvironment = A
    
    public var reader : R -> A {
        return f
    }
    
    public func runReader(environment : R) -> A {
        return reader(environment)
    }
    
    public func local(f : R -> R) -> Reader<R, A> {
        return Reader(reader • f)
    }
}

extension Reader : Functor {
    public typealias B = Any
    public typealias FB = Reader<R, B>
    
    public func fmap<B>(f : A -> B) -> Reader<R, B> {
        return mapReader(f)
    }
}

public func <^> <R, A, B>(f : A -> B, r : Reader<R, A>) -> Reader<R, B> {
    return r.fmap(f)
}

extension Reader : Pointed {
    public static func pure(f : A) -> Reader<R, A> {
        return Reader<R, A>.init { _ in f }
    }
}

extension Reader : Applicative {
    public typealias FAB = Reader<R, A -> B>
    
    public func ap(r : Reader<R, A -> B>) -> Reader<R, B> {
        return Reader<R, B>(runReader)
    }
}

public func <*> <R, A, B>(rfs : Reader<R, A -> B>, xs : Reader<R, A>) -> Reader<R, B>  {
    return Reader<R, B>.init({ (environment: R) -> B in
        let a = xs.runReader(environment)
        let ab = rfs.runReader(environment)
        let b = ab(a)
        return b
    })
}

extension Reader : ApplicativeOps {
    public typealias C = Any
    public typealias FC = Reader<R, C>
    public typealias D = Any
    public typealias FD = Reader<R, D>
    
    public static func liftA(f: A -> B) -> Reader<R, A> -> Reader<R, B> {
        return { a in Reader<R, A -> B>.pure(f) <*> a }
    }
    
    public static func liftA2(f: A -> B -> C) -> Reader<R, A> -> Reader<R, B> -> Reader<R, C> {
        return { a in { b in f <^> a <*> b  } }
    }
    
    public static func liftA3(f: A -> B -> C -> D) -> Reader<R, A> -> Reader<R, B> -> Reader<R, C> -> Reader<R, D> {
        return { a in { b in { c in f <^> a <*> b <*> c } } }
    }
}

extension Reader : Monad {
    public func bind(f: A -> Reader<R, B>) -> Reader<R, B> {
        return self >>- f
    }
}

func >>- <R, A, B>(r : Reader<R, A>, f : A -> Reader<R, B>) -> Reader<R, B> {
    return Reader<R, B>.init({ (environment: R) -> B in
        let a = r.runReader(environment)
        let readerB = f(a)
        let b = readerB.runReader(environment)
        return b
    })
}

extension Reader : MonadOps {
    public static func liftM(f: A -> B) -> Reader<R, A> -> Reader<R, B> {
        return { m1 in m1 >>- { x1 in Reader<R, B>.pure(f(x1)) } }
    }
    
    public static func liftM2(f: A -> B -> C) -> Reader<R, A> -> Reader<R, B> -> Reader<R, C> {
        return { m1 in { m2 in m1 >>- { x1 in m2 >>- { x2 in Reader<R, C>.pure(f(x1)(x2)) } } } }
    }
    
    public static func liftM3(f: A -> B -> C -> D) -> Reader<R, A> -> Reader<R, B> -> Reader<R, C> -> Reader<R, D> {
        return { m1 in { m2 in { m3 in m1 >>- { x1 in m2 >>- { x2 in m3 >>- { x3 in Reader<R, D>.pure(f(x1)(x2)(x3)) } } } } } }
    }
}

public func >>->> <R, A, B, C>(f : A -> Reader<R, B>, g : B -> Reader<R, C>) -> (A -> Reader<R, C>) {
    return { x in f(x) >>- g }
}

public func <<-<< <R, A, B, C>(g : B -> Reader<R, C>, f : A -> Reader<R, B>) -> (A -> Reader<R, C>) {
    return f >>->> g
}