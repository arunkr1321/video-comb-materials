import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

// MARK: - Collecting values

example(of: "collect") {
  ["A", "B", "C", "D", "E"].publisher
    .collect(2)
    .sink(receiveCompletion: { print($0) },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

// MARK: - Mapping values

example(of: "map") {
  let formatter = NumberFormatter()
  formatter.numberStyle = .spellOut

  [123, 4, 56].publisher
    .map {
      formatter.string(for: NSNumber(integerLiteral: $0)) ?? ""
    }
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
}

// MARK: - Replacing upstream output

example(of: "replaceNil") {
  ["A", nil, "C"].publisher
    .replaceNil(with: "-")
    .map { $0! }
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "replaceEmpty(with:)") {
  let empty = Empty<Int, Never>()

  empty
    .replaceEmpty(with: 1)
    .sink(receiveCompletion: { print($0) },
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "scan") {
  var dailyGainLoss: Int { .random(in: -10...10) }

  let august2019 = (0..<22)
    .map { _ in dailyGainLoss }
    .publisher

  august2019
    .scan(50) { latest, current in
      max(0, latest + current)
    }
    .sink(receiveValue: { _ in })
    .store(in: &subscriptions)
}

// MARK: - Flattening publishers

example(of: "flatMap") {
  let charlotte = Chatter(name: "Charlotte", message: "Hi, I'm Charlotte!")
  let james = Chatter(name: "James", message: "Hi, I'm James!")

  let chat = CurrentValueSubject<Chatter, Never>(charlotte)

  chat
    .flatMap(maxPublishers: .max(2)) { $0.message }
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

  charlotte.message.value = "Charlotte: How's it going?"

  chat.value = james

  james.message.value = "James: Doing great. You?"
  charlotte.message.value = "Charlotte: I'm doing fine thanks."

  let morgan = Chatter(name: "Morgan",
                       message: "Hey guys, what are you up to?")
  
  chat.value = morgan

  charlotte.message.value = "Did you hear something?"
}

/// Copyright (c) 2020 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
