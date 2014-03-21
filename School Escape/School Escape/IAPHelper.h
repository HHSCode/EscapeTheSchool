//
//  IAPHelper.h
//  School Escape
//
//  Created by Sudikoff Lab iMac on 3/21/14.
//  Copyright (c) 2014 Lordtechy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#define kBuy100Coins @"1000coin"

@interface IAPHelper : NSObject <SKProductsRequestDelegate>

-(void)requestProductData;
-(NSArray*)getProductData;

@end
