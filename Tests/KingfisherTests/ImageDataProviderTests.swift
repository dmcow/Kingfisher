//
//  ImageDataProviderTests.swift
//  Kingfisher
//
//  Created by onevcat on 2018/11/18.
//
//  Copyright (c) 2019 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import XCTest
import Kingfisher

class ImageDataProviderTests: XCTestCase {
    
    func testLocalFileImageDataProvider() {
        let fm = FileManager.default
        let document = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = document.appendingPathComponent("test")
        try! testImageData.write(to: fileURL)
        
        let provider = LocalFileImageDataProvider(fileURL: fileURL)
        XCTAssertEqual(provider.cacheKey, fileURL.absoluteString)
        XCTAssertEqual(provider.fileURL, fileURL)
        
        let exp = expectation(description: #function)
        provider.data { result in
            XCTAssertEqual(result.value, testImageData)
            try! fm.removeItem(at: fileURL)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testLocalFileImageDataProviderMainQueue() {
        let fm = FileManager.default
        let document = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = document.appendingPathComponent("test")
        try! testImageData.write(to: fileURL)
        
        let provider = LocalFileImageDataProvider(fileURL: fileURL, loadingQueue: .mainCurrentOrAsync)
        XCTAssertEqual(provider.cacheKey, fileURL.absoluteString)
        XCTAssertEqual(provider.fileURL, fileURL)
        
        var called = false
        provider.data { result in
            XCTAssertEqual(result.value, testImageData)
            try! fm.removeItem(at: fileURL)
            called = true
        }

        XCTAssertTrue(called)
    }
    
    func testBase64ImageDataProvider() {
        let base64String = testImageData.base64EncodedString()
        let provider = Base64ImageDataProvider(base64String: base64String, cacheKey: "123")
        XCTAssertEqual(provider.cacheKey, "123")
        var syncCalled = false
        provider.data { result in
            XCTAssertEqual(result.value, testImageData)
            syncCalled = true
        }
        
        XCTAssertTrue(syncCalled)
    }
    
}
