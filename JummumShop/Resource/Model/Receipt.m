//
//  Receipt.m
//  FFD
//
//  Created by Thidaporn Kijkamjai on 9/23/2560 BE.
//  Copyright © 2560 Appxelent. All rights reserved.
//

#import "Receipt.h"
#import "SharedReceipt.h"
#import "Utility.h"


@implementation Receipt

-(Receipt *)initWithBranchID:(NSInteger)branchID customerTableID:(NSInteger)customerTableID memberID:(NSInteger)memberID servingPerson:(NSInteger)servingPerson customerType:(NSInteger)customerType openTableDate:(NSDate *)openTableDate cashAmount:(float)cashAmount cashReceive:(float)cashReceive creditCardType:(NSInteger)creditCardType creditCardNo:(NSString *)creditCardNo creditCardAmount:(float)creditCardAmount transferDate:(NSDate *)transferDate transferAmount:(float)transferAmount remark:(NSString *)remark discountType:(NSInteger)discountType discountAmount:(float)discountAmount discountValue:(float)discountValue discountReason:(NSString *)discountReason serviceChargePercent:(float)serviceChargePercent serviceChargeValue:(float)serviceChargeValue priceIncludeVat:(NSInteger)priceIncludeVat vatPercent:(float)vatPercent vatValue:(float)vatValue status:(NSInteger)status statusRoute:(NSString *)statusRoute receiptNoID:(NSString *)receiptNoID receiptNoTaxID:(NSString *)receiptNoTaxID receiptDate:(NSDate *)receiptDate mergeReceiptID:(NSInteger)mergeReceiptID
{
    self = [super init];
    if(self)
    {
        self.receiptID = [Receipt getNextID];
        self.branchID = branchID;
        self.customerTableID = customerTableID;
        self.memberID = memberID;
        self.servingPerson = servingPerson;
        self.customerType = customerType;
        self.openTableDate = openTableDate;
        self.cashAmount = cashAmount;
        self.cashReceive = cashReceive;
        self.creditCardType = creditCardType;
        self.creditCardNo = creditCardNo;
        self.creditCardAmount = creditCardAmount;
        self.transferDate = transferDate;
        self.transferAmount = transferAmount;
        self.remark = remark;
        self.discountType = discountType;
        self.discountAmount = discountAmount;
        self.discountValue = discountValue;
        self.discountReason = discountReason;
        self.serviceChargePercent = serviceChargePercent;
        self.serviceChargeValue = serviceChargeValue;
        self.priceIncludeVat = priceIncludeVat;
        self.vatPercent = vatPercent;
        self.vatValue = vatValue;
        self.status = status;
        self.statusRoute = statusRoute;
        self.receiptNoID = receiptNoID;
        self.receiptNoTaxID = receiptNoTaxID;
        self.receiptDate = receiptDate;
        self.mergeReceiptID = mergeReceiptID;
        self.modifiedUser = [Utility modifiedUser];
        self.modifiedDate = [Utility currentDateTime];
    }
    return self;
}

+(NSInteger)getNextID
{
    NSString *primaryKeyName = @"receiptID";
    NSString *propertyName = [NSString stringWithFormat:@"_%@",primaryKeyName];
    NSMutableArray *dataList = [SharedReceipt sharedReceipt].receiptList;
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:propertyName ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray *sortArray = [dataList sortedArrayUsingDescriptors:sortDescriptors];
    dataList = [sortArray mutableCopy];
    
    if([dataList count] == 0)
    {
        return -1;
    }
    else
    {
        id value = [dataList[0] valueForKey:primaryKeyName];
        if([value integerValue]>0)
        {
            return -1;
        }
        else
        {
            return [value integerValue]-1;
        }
    }
}

+(void)addObject:(Receipt *)receipt
{
    NSMutableArray *dataList = [SharedReceipt sharedReceipt].receiptList;
    [dataList addObject:receipt];
}

+(void)removeObject:(Receipt *)receipt
{
    NSMutableArray *dataList = [SharedReceipt sharedReceipt].receiptList;
    [dataList removeObject:receipt];
}

+(void)addList:(NSMutableArray *)receiptList
{
    NSMutableArray *dataList = [SharedReceipt sharedReceipt].receiptList;
    [dataList addObjectsFromArray:receiptList];
}

+(void)removeList:(NSMutableArray *)receiptList
{
    NSMutableArray *dataList = [SharedReceipt sharedReceipt].receiptList;
    [dataList removeObjectsInArray:receiptList];
}

+(Receipt *)getReceipt:(NSInteger)receiptID
{
    NSMutableArray *dataList = [SharedReceipt sharedReceipt].receiptList;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_receiptID = %ld",receiptID];
    NSArray *filterArray = [dataList filteredArrayUsingPredicate:predicate];
    if([filterArray count] > 0)
    {
        return filterArray[0];
    }
    return nil;
}

-(id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy)
    {
        ((Receipt *)copy).receiptID = self.receiptID;
        ((Receipt *)copy).branchID = self.branchID;
        ((Receipt *)copy).customerTableID = self.customerTableID;
        ((Receipt *)copy).memberID = self.memberID;
        ((Receipt *)copy).servingPerson = self.servingPerson;
        ((Receipt *)copy).customerType = self.customerType;
        [copy setOpenTableDate:self.openTableDate];
        ((Receipt *)copy).cashAmount = self.cashAmount;
        ((Receipt *)copy).cashReceive = self.cashReceive;
        ((Receipt *)copy).creditCardType = self.creditCardType;
        [copy setCreditCardNo:self.creditCardNo];
        ((Receipt *)copy).creditCardAmount = self.creditCardAmount;
        [copy setTransferDate:self.transferDate];
        ((Receipt *)copy).transferAmount = self.transferAmount;
        [copy setRemark:self.remark];
        ((Receipt *)copy).discountType = self.discountType;
        ((Receipt *)copy).discountAmount = self.discountAmount;
        ((Receipt *)copy).discountValue = self.discountValue;
        [copy setDiscountReason:self.discountReason];
        ((Receipt *)copy).serviceChargePercent = self.serviceChargePercent;
        ((Receipt *)copy).serviceChargeValue = self.serviceChargeValue;
        ((Receipt *)copy).priceIncludeVat = self.priceIncludeVat;
        ((Receipt *)copy).vatPercent = self.vatPercent;
        ((Receipt *)copy).vatValue = self.vatValue;
        ((Receipt *)copy).status = self.status;
        [copy setStatusRoute:self.statusRoute];
        [copy setReceiptNoID:self.receiptNoID];
        [copy setReceiptNoTaxID:self.receiptNoTaxID];
        [copy setReceiptDate:self.receiptDate];
        ((Receipt *)copy).mergeReceiptID = self.mergeReceiptID;
        [copy setModifiedUser:[Utility modifiedUser]];
        [copy setModifiedDate:[Utility currentDateTime]];
        ((Receipt *)copy).replaceSelf = self.replaceSelf;
        ((Receipt *)copy).idInserted = self.idInserted;
    }
    
    return copy;
}

-(BOOL)editReceipt:(Receipt *)editingReceipt
{
    if(self.receiptID == editingReceipt.receiptID
       && self.branchID == editingReceipt.branchID
       && self.customerTableID == editingReceipt.customerTableID
       && self.memberID == editingReceipt.memberID
       && self.servingPerson == editingReceipt.servingPerson
       && self.customerType == editingReceipt.customerType
       && [self.openTableDate isEqual:editingReceipt.openTableDate]
       && self.cashAmount == editingReceipt.cashAmount
       && self.cashReceive == editingReceipt.cashReceive
       && self.creditCardType == editingReceipt.creditCardType
       && [self.creditCardNo isEqualToString:editingReceipt.creditCardNo]
       && self.creditCardAmount == editingReceipt.creditCardAmount
       && [self.transferDate isEqual:editingReceipt.transferDate]
       && self.transferAmount == editingReceipt.transferAmount
       && [self.remark isEqualToString:editingReceipt.remark]
       && self.discountType == editingReceipt.discountType
       && self.discountAmount == editingReceipt.discountAmount
       && self.discountValue == editingReceipt.discountValue
       && [self.discountReason isEqualToString:editingReceipt.discountReason]
       && self.serviceChargePercent == editingReceipt.serviceChargePercent
       && self.serviceChargeValue == editingReceipt.serviceChargeValue
       && self.priceIncludeVat == editingReceipt.priceIncludeVat
       && self.vatPercent == editingReceipt.vatPercent
       && self.vatValue == editingReceipt.vatValue
       && self.status == editingReceipt.status
       && [self.statusRoute isEqualToString:editingReceipt.statusRoute]
       && [self.receiptNoID isEqualToString:editingReceipt.receiptNoID]
       && [self.receiptNoTaxID isEqualToString:editingReceipt.receiptNoTaxID]
       && [self.receiptDate isEqual:editingReceipt.receiptDate]
       && self.mergeReceiptID == editingReceipt.mergeReceiptID
       )
    {
        return NO;
    }
    return YES;
}

+(Receipt *)copyFrom:(Receipt *)fromReceipt to:(Receipt *)toReceipt
{
    toReceipt.receiptID = fromReceipt.receiptID;
    toReceipt.branchID = fromReceipt.branchID;
    toReceipt.customerTableID = fromReceipt.customerTableID;
    toReceipt.memberID = fromReceipt.memberID;
    toReceipt.servingPerson = fromReceipt.servingPerson;
    toReceipt.customerType = fromReceipt.customerType;
    toReceipt.openTableDate = fromReceipt.openTableDate;
    toReceipt.cashAmount = fromReceipt.cashAmount;
    toReceipt.cashReceive = fromReceipt.cashReceive;
    toReceipt.creditCardType = fromReceipt.creditCardType;
    toReceipt.creditCardNo = fromReceipt.creditCardNo;
    toReceipt.creditCardAmount = fromReceipt.creditCardAmount;
    toReceipt.transferDate = fromReceipt.transferDate;
    toReceipt.transferAmount = fromReceipt.transferAmount;
    toReceipt.remark = fromReceipt.remark;
    toReceipt.discountType = fromReceipt.discountType;
    toReceipt.discountAmount = fromReceipt.discountAmount;
    toReceipt.discountValue = fromReceipt.discountValue;
    toReceipt.discountReason = fromReceipt.discountReason;
    toReceipt.serviceChargePercent = fromReceipt.serviceChargePercent;
    toReceipt.serviceChargeValue = fromReceipt.serviceChargeValue;
    toReceipt.priceIncludeVat = fromReceipt.priceIncludeVat;
    toReceipt.vatPercent = fromReceipt.vatPercent;
    toReceipt.vatValue = fromReceipt.vatValue;
    toReceipt.status = fromReceipt.status;
    toReceipt.statusRoute = fromReceipt.statusRoute;
    toReceipt.receiptNoID = fromReceipt.receiptNoID;
    toReceipt.receiptNoTaxID = fromReceipt.receiptNoTaxID;
    toReceipt.receiptDate = fromReceipt.receiptDate;
    toReceipt.mergeReceiptID = fromReceipt.mergeReceiptID;
    toReceipt.modifiedUser = [Utility modifiedUser];
    toReceipt.modifiedDate = [Utility currentDateTime];
    
    return toReceipt;
}


+(NSMutableArray *)getReceiptListWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate statusList:(NSArray *)statusList
{
    NSMutableArray *receiptList = [[NSMutableArray alloc]init];
    NSMutableArray *dataList = [SharedReceipt sharedReceipt].receiptList;
    
    for(NSString *status in statusList)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_receiptDate BETWEEN %@ and _status = %ld", [NSArray arrayWithObjects:startDate, endDate, nil],[status integerValue]];
        NSArray *filterArray = [dataList filteredArrayUsingPredicate:predicate];
        [receiptList addObjectsFromArray:filterArray];
    }
    
    
    return [self sortList:receiptList];
}

+(NSMutableArray *)getReceiptListWithReceiptNoID:(NSString *)receiptNoID
{
    NSMutableArray *dataList = [SharedReceipt sharedReceipt].receiptList;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_receiptNoID = %@",receiptNoID];
    NSArray *filterArray = [dataList filteredArrayUsingPredicate:predicate];
    
    return [filterArray mutableCopy];
}

+(NSMutableArray *)getRemarkReceiptListWithMemeberID:(NSInteger)memberID
{
    NSMutableArray *dataList = [SharedReceipt sharedReceipt].receiptList;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_memberID = %ld and _remark != %@",memberID,@""];
    NSArray *filterArray = [dataList filteredArrayUsingPredicate:predicate];
    
    
    
    return [filterArray mutableCopy];
}

+(NSMutableArray *)getReceiptListWithMemeberID:(NSInteger)memberID
{
    NSMutableArray *dataList = [SharedReceipt sharedReceipt].receiptList;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_memberID = %ld",memberID];
    NSArray *filterArray = [dataList filteredArrayUsingPredicate:predicate];
    
    
    
    return [filterArray mutableCopy];
}

+(NSMutableArray *)sortList:(NSMutableArray *)receiptList
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"_receiptDate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray *sortArray = [receiptList sortedArrayUsingDescriptors:sortDescriptors];
    
    
    return [sortArray mutableCopy];
}

+(float)getAllCashAmountWithReceiptDate:(NSDate *)date
{
    NSDate *startOfTheDay = [Utility setStartOfTheDay:date];
    NSDate *endOfTheDay = [Utility setEndOfTheDay:date];
    NSMutableArray *dataList = [SharedReceipt sharedReceipt].receiptList;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_receiptDate >= %@ and _receiptDate <= %@",startOfTheDay,endOfTheDay];
    NSArray *filterArray = [dataList filteredArrayUsingPredicate:predicate];
    
    float sum = 0;
    for(Receipt *item in filterArray)
    {
        sum += item.cashAmount;
    }
    
    return sum;
}

+(float)getAllCreditAmountWithReceiptDate:(NSDate *)date
{
    NSDate *startOfTheDay = [Utility setStartOfTheDay:date];
    NSDate *endOfTheDay = [Utility setEndOfTheDay:date];
    NSMutableArray *dataList = [SharedReceipt sharedReceipt].receiptList;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_receiptDate >= %@ and _receiptDate <= %@",startOfTheDay,endOfTheDay];
    NSArray *filterArray = [dataList filteredArrayUsingPredicate:predicate];
    
    float sum = 0;
    for(Receipt *item in filterArray)
    {
        sum += item.creditCardAmount;
    }
    
    return sum;
}

+(float)getAllTransferAmountWithReceiptDate:(NSDate *)date
{
    NSDate *startOfTheDay = [Utility setStartOfTheDay:date];
    NSDate *endOfTheDay = [Utility setEndOfTheDay:date];
    NSMutableArray *dataList = [SharedReceipt sharedReceipt].receiptList;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_receiptDate >= %@ and _receiptDate <= %@",startOfTheDay,endOfTheDay];
    NSArray *filterArray = [dataList filteredArrayUsingPredicate:predicate];
    
    float sum = 0;
    for(Receipt *item in filterArray)
    {
        sum += item.transferAmount;
    }
    
    return sum;
}

+(NSDate *)getMaxModifiedDateWithMemberID:(NSInteger)memberID
{
    NSMutableArray *dataList = [SharedReceipt sharedReceipt].receiptList;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_memberID = %ld",memberID];
    NSArray *filterArray = [dataList filteredArrayUsingPredicate:predicate];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"_modifiedDate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    NSArray *sortArray = [filterArray sortedArrayUsingDescriptors:sortDescriptors];
    
    if([sortArray count] > 0)
    {
        Receipt *receipt = sortArray[0];
        return receipt.modifiedDate;
    }
    
    return nil;
}

+(void)updateStatusList:(NSMutableArray *)receiptList
{
    NSMutableArray *dataList = [SharedReceipt sharedReceipt].receiptList;
    for(Receipt *item in receiptList)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_receiptID = %ld",item.receiptID];
        NSArray *filterArray = [dataList filteredArrayUsingPredicate:predicate];
        if([filterArray count]>0)
        {
            Receipt *receipt = filterArray[0];
            receipt.status = item.status;
            receipt.statusRoute = item.statusRoute;
        }
    }
}

+(NSMutableArray *)getReceiptList
{
    return [SharedReceipt sharedReceipt].receiptList;
}

+(void)removeAllObjects
{
    NSMutableArray *dataList = [SharedReceipt sharedReceipt].receiptList;
    [dataList removeAllObjects];
}

+(float)getTotalAmount:(Receipt *)receipt
{
    return receipt.cashAmount+receipt.creditCardAmount+receipt.transferAmount;
}

+(NSString *)getStrStatus:(Receipt *)receipt
{
    NSString *strStatus;
    switch (receipt.status)
    {
        case 2:
        {
            strStatus = @"Order sent";
        }
            break;
        case 5:
        {
            strStatus = @"Processing..";
        }
            break;
        case 6:
        {
            strStatus = @"Delivered";
        }
            break;
        case 7:
        {
            strStatus = @"Pending cancel";
        }
            break;
        case 8:
        {
            strStatus = @"Order dispute in process";
        }
            break;
        case 9:
        {
            strStatus = @"Order cancelled";
        }
            break;
        case 10:
        {
            strStatus = @"Order dispute finished";
        }
            break;
        case 11:
        {
            strStatus = @"Negotiate";
        }
            break;
        case 12:
        {
            strStatus = @"Review dispute";
        }
            break;
        case 13:
        {
            strStatus = @"Review dispute in process";
        }
        break;
        case 14:
        {
            strStatus = @"Order dispute finished";
        }
        break;
        default:
            break;
    }
    
    return strStatus;
}

+(UIColor *)getStatusColor:(Receipt *)receipt
{
    UIColor *color;
    switch (receipt.status)
    {
        case 2:
        {
            color = mOrange;
        }
            break;
        case 5:
        {
            color = mOrange;
        }
            break;
        case 6:
        {
            color = mGreen;
        }
            break;
        case 7:
        {
            color = mOrange;
        }
            break;
        case 8:
        {
            color = mOrange;
        }
            break;
        case 9:
        {
            color = mRed;
        }
            break;
        case 10:
        {
            color = mRed;
        }
            break;
        case 11:
        {
            color = mOrange;
        }
            break;
        case 12:
        {
            color = mOrange;
        }
            break;
        case 13:
        {
            color = mOrange;
        }
        break;
        case 14:
        {
            color = mRed;
        }
        break;
        
        default:
            break;
    }
    
    return color;
}

+(NSInteger)getStateBeforeLast:(Receipt *)receipt
{
    NSArray *statusList = [receipt.statusRoute componentsSeparatedByString:@","];
    if([statusList count]>1)
    {
        return [statusList[[statusList count]-2] integerValue];
    }
    return 0;
}

+(Receipt *)getReceipt:(NSInteger)receiptID branchID:(NSInteger)branchID
{
    NSMutableArray *dataList = [SharedReceipt sharedReceipt].receiptList;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_receiptID = %ld and _branchID = %ld",receiptID,branchID];
    NSArray *filterArray = [dataList filteredArrayUsingPredicate:predicate];
    if([filterArray count] > 0)
    {
        return filterArray[0];
    }
    return nil;
}

+(NSMutableArray *)getReceiptListWithStatus:(NSInteger)status branchID:(NSInteger)branchID
{
    NSMutableArray *dataList = [SharedReceipt sharedReceipt].receiptList;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_status = %ld and _branchID = %ld",status,branchID];
    NSArray *filterArray = [dataList filteredArrayUsingPredicate:predicate];
    
    return [filterArray mutableCopy];
}

+(void)updateStatus:(Receipt *)receipt
{
    Receipt *selectedReceipt = [self getReceipt:receipt.receiptID branchID:receipt.branchID];
    selectedReceipt.status = receipt.status;
    selectedReceipt.statusRoute = receipt.statusRoute;
}

+(NSMutableArray *)sortListDesc:(NSMutableArray *)receiptList
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"_receiptDate" ascending:NO];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"_receiptID" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor,sortDescriptor2, nil];
    NSArray *sortArray = [receiptList sortedArrayUsingDescriptors:sortDescriptors];
    
    
    return [sortArray mutableCopy];
}

@end
