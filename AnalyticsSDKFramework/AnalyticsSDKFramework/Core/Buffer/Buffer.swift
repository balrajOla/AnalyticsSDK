//
//  Buffer.swift
//  AnalyticsSDKFramework
//
//  Created by Balraj Singh on 09/09/19.
//  Copyright © 2019 Balraj Singh. All rights reserved.
//

import Foundation
import RxSwift

internal struct Buffer {
    //MARK: - Private Variables
    fileprivate var streams: PublishSubject<(event: String, payload: [String: Any]?, priority: NAAnalyticsEventPriority)>
    fileprivate static let defaultBufferConfig = (interval: 1, count: 1)
    fileprivate let disposableBag = DisposeBag()
    public typealias EventDataType = (event: String, payload: [String: Any]?, priority: NAAnalyticsEventPriority)
    
    //MARK: - Constructor
    private init(with handler: @escaping ((_ data: [EventDataType]) -> ()),
                 _ configuration: [NAAnalyticsEventPriority: (interval: Int, count: Int)]) {
        self.streams = PublishSubject<(event: String, payload: [String: Any]?, priority: NAAnalyticsEventPriority)>()
        self.subscribe(toHandler: handler)(configuration)
    }
    
    //MARK: - Public Functions
    // This function creates an instance of Buffer and returns back
    public func create(withHandler handler: @escaping ((_ data: [EventDataType]) -> ()))
        -> (_ configuration: [NAAnalyticsEventPriority: (interval: Int, count: Int)])
        -> Buffer {
            return { (_ configuration: [NAAnalyticsEventPriority: (interval: Int, count: Int)]) -> Buffer in
                return Buffer(with: handler, configuration)
            }
    }
    
    /// This function pushes a data with ceratin priority
    /// - Parameter priority - determines the priority of the data
    /// - Parameter data - the actual data that needs to be buffered and pushed forward
    public func push(withPriority priority: NAAnalyticsEventPriority)
        -> (_ data: (event: String, payload: [String: Any]?))
        -> Void {
            return { (_ data: (event: String, payload: [String: Any]?)) -> Void in
                self.streams.onNext((event: data.event, payload: data.payload, priority: priority))
            }
    }
    
    /// This function ends and flush out all the pending data from the buffer
    public func end() {
        self.streams.onCompleted()
    }
    
    //MARK: - Private functions
    private func subscribe(toHandler handler: @escaping ((_ data: [EventDataType]) -> ()))
        -> (_ configuration: [NAAnalyticsEventPriority: (interval: Int, count: Int)])
        -> Void {
            return { (_ configuration: [NAAnalyticsEventPriority: (interval: Int, count: Int)]) -> Void in
                let streamHandler = self.setStream(with: handler)
                
                streamHandler(self.streams.filter{ $0.priority == .high })(configuration[.high] ?? Buffer.defaultBufferConfig)
                streamHandler(self.streams.filter{ $0.priority == .medium })(configuration[.medium] ?? Buffer.defaultBufferConfig)
                streamHandler(self.streams.filter{ $0.priority == .low })(configuration[.low] ?? Buffer.defaultBufferConfig)
            }
    }
    
    private func setStream (with handler: @escaping ((_ data: [EventDataType]) -> ()))
        -> (_ stream: Observable<(event: String, payload: [String : Any]?, priority: NAAnalyticsEventPriority)>)
        -> (_ config: (interval: Int, count: Int))
        -> Void {
            return { (_ stream: Observable<(event: String, payload: [String : Any]?, priority: NAAnalyticsEventPriority)>)
                -> (_ config: (interval: Int, count: Int))
                -> Void in
                return { (_ config: (interval: Int, count: Int))
                    -> Void in
                    stream.buffer(timeSpan: RxTimeInterval.seconds(config.interval), count: config.count, scheduler: MainScheduler.instance)
                        .subscribe({ (event) in
                            switch event {
                            case .next(let eventData):
                                handler(eventData)
                            case .completed, .error(_ ): break
                            }
                        }).disposed(by: self.disposableBag)
                }
            }
    }
}
