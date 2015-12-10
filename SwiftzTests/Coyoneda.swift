//
//  IdentitySpec.swift
//  Swiftz
//
//  Created by Simon Richardson on 10/12/2015.
//  Copyright © 2015 TypeLift. All rights reserved.
//

import XCTest
import Swiftz
import SwiftCheck

extension Identity where T : Arbitrary {
    public static var arbitrary : Gen<Identity<A>> {
        return Identity.pure <^> A.arbitrary
    }
}

extension Identity : WitnessedArbitrary {
    public typealias Param = T
    
    public static func forAllWitnessed<F, A : Arbitrary>(wit : A -> T)(pf : (Coyoneda<F, T> -> Testable)) -> Property {
        return forAllShrink(Coyoneda<F, A>.arbitrary, shrinker: const([]), f: { bl in
            return pf(bl.fmap(wit))
        })
    }
}

class IdentitySpec : XCTestCase {
    func testProperties() {
        property("Coyoneda obeys the Functor identity law") <- forAll { (x : Coyoneda<Identity<Int>, Int>) in
            return (x.fmap(identity)) == identity(x)
        }
        
        property("Coyoneda obeys the Functor composition law") <- forAll { (f : ArrowOf<Int, Int>, g : ArrowOf<Int, Int>) in
            return forAll { (x : Coyoneda<Identity<Int>, Int>) in
                return ((f.getArrow • g.getArrow) <^> x) == (x.fmap(g.getArrow).fmap(f.getArrow))
            }
        }
    }
}
