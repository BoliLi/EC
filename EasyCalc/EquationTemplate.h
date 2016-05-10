//
//  EquationTemplate.h
//  EasyCalc
//
//  Created by LiBoli on 16/5/6.
//  Copyright © 2016年 LiBoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EquationBlock;

@interface EquationTemplate : NSObject <NSCoding>
@property NSString * title;
@property NSString * detailTitle;
@property EquationBlock *root;
@end
