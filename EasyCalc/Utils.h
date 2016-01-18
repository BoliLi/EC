//
//  Utils.h
//  EasyCalc
//
//  Created by LiBoli on 15/11/23.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#ifndef Utils_h
#define Utils_h

EquationTextLayer *locaLastTxtLyr(Equation *e, id blk);
EquationTextLayer *findPrevTxtLayer(Equation *e, id blk);
id getPrevBlk(Equation *E, id curBlk);
void cfgEqnBySlctBlk(Equation *e, id b, CGPoint curPoint);
bool rectContainsRect(CGRect rect1, CGRect rect2);
NSMutableString *equationToString(EquationBlock *parent);
#endif /* Utils_h */
