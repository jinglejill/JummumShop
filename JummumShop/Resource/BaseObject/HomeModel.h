//
//  HomeModel.h
//  SaleAndInventoryManagement
//
//  Created by Thidaporn Kijkamjai on 7/9/2558 BE.
//  Copyright (c) 2558 Thidaporn Kijkamjai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserAccount.h"
#import <UIKit/UIKit.h>

@protocol HomeModelProtocol <NSObject>

@optional
- (void)itemsDownloaded:(NSArray *)items;
- (void)applicationExpired;
- (void)itemsInserted;
- (void)itemsUpdated;
- (void)itemsUpdated:(NSString *)alert;
- (void)itemsSynced:(NSArray *)items;
- (void)itemsDeleted;
- (void)emailSent;
- (void)photoUploaded;
- (void)connectionFail;
- (void)itemsInsertedWithReturnID:(NSString *)strID;
- (void)itemsInsertedWithReturnData:(NSArray *)items;
- (void)alertMsg:(NSString *)msg;
- (void)itemsFail;
- (void)salesGenerated:(NSString *)fileName;
- (void)salesGeneratedFail;
- (void)downloadProgress:(float)percent;
- (void)removeOverlayViewConnectionFail;
@end


enum enumAction
{
    list,
    add,
    edit,
    delete
};

@interface HomeModel : NSObject<NSURLSessionDataDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>

@property (nonatomic, weak) id<HomeModelProtocol> delegate;
@property (nonatomic) enum enumDB propCurrentDB;
@property (nonatomic) enum enumDB propCurrentDBUpdate;
@property (nonatomic) enum enumDB propCurrentDBInsert;
@property (nonatomic, retain) NSMutableData *dataToDownload;
@property (nonatomic) float downloadSize;
@property (nonatomic) NSInteger printWithAddress;


- (void)downloadItems:(enum enumDB)currentDB;
- (void)downloadItems:(enum enumDB)currentDB withData:(NSObject *)data;
- (void)insertItems:(enum enumDB)currentDB withData:(NSObject *)data actionScreen:(NSString *)actionScreen;
- (void)updateItems:(enum enumDB)currentDB withData:(NSObject *)data actionScreen:(NSString *)actionScreen;
- (void)deleteItems:(enum enumDB)currentDB withData:(NSObject *)data actionScreen:(NSString *)actionScreen;
- (void)syncItems:(enum enumDB)currentDB withData:(NSObject *)data;
//- (void)syncItemsWithoutLoadViewProcess:(enum enumDB)currentDB withData:(NSObject *)data;
- (void)sendEmail:(NSString *)toAddress withSubject:(NSString *)subject andBody:(NSString *)body;
- (void)uploadPhoto:(NSData *)photo fileName:(NSString *)fileName;
- (void)downloadImageWithFileName:(NSString *)fileName completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock;
- (void)downloadFileWithFileName:(NSString *)fileName completionBlock:(void (^)(BOOL succeeded, NSData *data))completionBlock;
@end

