//
//  Coyoneda.swift
//  Swiftz
//
//  Created by Simon Richardson on 10/12/2015.
//  Copyright © 2015 TypeLift. All rights reserved.
//

public struct Coyoneda<F, A> {
    public let fi : F
    public let k : Function<Swiftz.Any, A>
    
    public init(_ fi : F, _ k : Swift.Any -> A) {
        self.fi = fi
        self.k = Function.arr(k)
    }
}

public func lift<F, A>(s : F) -> Coyoneda<F, A> {
    return Coyoneda<F, A>(s, Function.id())
}

extension Coyoneda : Functor {
    public typealias B = Swift.Any
    
    public func fmap<B>(f : A -> B) -> Coyoneda<F, B> {
        return Coyoneda<F, B>(self.fi, Function.arr(f) >>> self.k)
    }
}