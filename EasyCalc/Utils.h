//
//  Utils.h
//  EasyCalc
//
//  Created by LiBoli on 15/11/23.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#ifndef Utils_h
#define Utils_h

EquationTextLayer *findLastTxtLayer(Equation *e, id blk);
EquationTextLayer *findPrevTxtLayer(Equation *e, id blk);
void cfgEqnBySlctBlk(Equation *e, id b, CGPoint curPoint);
bool rectContainsRect(CGRect rect1, CGRect rect2);
#endif /* Utils_h */
