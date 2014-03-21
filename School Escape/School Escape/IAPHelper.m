//
//  IAPHelper.m
//  School Escape
//
//  Created by Sudikoff Lab iMac on 3/21/14.
//  Copyright (c) 2014 Lordtechy. All rights reserved.
//

#import "IAPHelper.h"

@implementation IAPHelper{
    NSArray* products;
}

-(void)requestProductData{
    products = nil;
    SKProductsRequest* request = [[SKProductsRequest alloc]initWithProductIdentifiers:[NSSet setWithObject:kBuy100Coins]];
    [request setDelegate:self];
    [request start];
    
}

-(NSArray *)getProductData{
    return products;
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    NSLog(@"Request worked!");
    products = [NSArray arrayWithArray:response.products];
}

-(void)requestDidFinish:(SKRequest *)request{
    NSLog(@"Request Over");
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"Request failed with error: \n%@",error);
    [self requestProductData];
}

@end
