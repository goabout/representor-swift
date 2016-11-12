//
//  HTTPTransitionTests.swift
//  Representor
//
//  Created by Kyle Fuller on 04/11/2014.
//  Copyright (c) 2014 Apiary. All rights reserved.
//

import Foundation
import XCTest
import Representor


class InputPropertyTests : XCTestCase {
  var property:InputProperty<Any>!

  override func setUp() {
    super.setUp()
    property = InputProperty<Any>(value:"Kyle Fuller", defaultValue:nil)
  }

  func testHasValue() {
    XCTAssertEqual(property.value as? String, "Kyle Fuller")
  }

  func testHasDefaultValue() {
    XCTAssertTrue(property.defaultValue == nil)
  }

  func testEquality() {
    XCTAssertEqual(property, InputProperty<Any>(value:"Kyle Fuller", defaultValue:nil))
    XCTAssertNotEqual(property, InputProperty<Any>(value:"Kyle Fuller", defaultValue:"Name"))
  }
}


class HTTPTransitionTests : XCTestCase {
  var transition:HTTPTransition!

  override func setUp() {
    super.setUp()
    transition = HTTPTransition(uri:"/self/")
  }

  func testHasURI() {
    XCTAssertEqual(transition.uri, "/self/")
  }

  func testHasAttributes() {
    XCTAssertEqual(transition.attributes.count, 0)
  }

  func testHasParameters() {
    XCTAssertEqual(transition.parameters.count, 0)
  }

  func testHasMethod() {
    XCTAssertEqual(transition.method, "GET")
  }

  func testHasContentType() {
    XCTAssertEqual(transition.suggestedContentTypes, [])
  }

  func testEquality() {
    XCTAssertEqual(transition, HTTPTransition(uri:"/self/"))
    XCTAssertNotEqual(transition, HTTPTransition(uri:"/next/"))
  }

  func testHashValue() {
    let transition1 = HTTPTransition(uri:"/self/")
    let transition2 = HTTPTransition(uri:"/self/")
    XCTAssertEqual(transition1.hashValue, transition2.hashValue)
  }
}
