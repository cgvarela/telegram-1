//
//  TGDownloadWorker.h
//  Telegraph
//
//  Created by Peter on 14/02/14.
//
//

#import <Foundation/Foundation.h>

@class MTContext;

@class TGNetworkWorker;
@class MTRequestMessageService;
@class MTRequest;
@class TGNetworkWorkerGuard;

@protocol TGNetworkWorkerDelegate <NSObject>

@optional

- (void)networkWorkerReadyToBeRemoved:(TGNetworkWorker *)networkWorker;
- (void)networkWorkerDidBecomeAvailable:(TGNetworkWorker *)networkWorker;

@end

@interface TGNetworkWorker : NSObject

@property (nonatomic, weak) id<TGNetworkWorkerDelegate> delegate;

@property (nonatomic, readonly) NSInteger datacenterId;

- (instancetype)initWithContext:(MTContext *)context datacenterId:(NSInteger)datacenterId masterDatacenterId:(NSInteger)masterDatacenterId queue:(ASQueue *)queue;

-(void)update;

- (bool)isBusy;
- (void)setIsBusy:(bool)isBusy;
- (void)updateReadyToBeRemoved;
- (void)addRequest:(MTRequest *)request;
- (void)cancelRequestById:(id)requestId;

@end

@interface TGNetworkWorkerGuard : NSObject

@property (nonatomic, weak) TGNetworkWorker *worker;

- (instancetype)initWithWorker:(TGNetworkWorker *)worker;
- (TGNetworkWorker *)strongWorker;
- (void)releaseWorker;

@end
