//
//  CalcBoard.h
//  EasyCalc
//
//  Created by LiBoli on 16/3/30.
//  Copyright © 2016年 LiBoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Equation;
@class DisplayView;

@interface CalcBoard : NSObject <NSCoding>
@property DisplayView *view;
@property NSMutableArray *eqList;
@property int curEqIdx;
@property Equation *curEq;
@end
