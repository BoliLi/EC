//
//  Equation.m
//  EasyCalc
//
//  Created by LiBoli on 15/11/20.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#import "Global.h"
#import "Equation.h"
#import "EquationBlock.h"
#import "EquationTextLayer.h"
#import "RadicalBlock.h"
#import "FractionBarLayer.h"
#import "WrapedEqTxtLyr.h"
#import "Parentheses.h"
#import "Utils.h"
#import "CalcBoard.h"


@class EquationTextLayer;
@class EquationBlock;

@implementation Equation
@synthesize guid_cnt;
@synthesize root;
@synthesize par;
@synthesize equalsign;
@synthesize result;
@synthesize timeRec;
@synthesize separator;
@synthesize mainFontLevel;

//-(id) init {
//    self = [super init];
//    if (self) {
//        guid_cnt = 0;
//        curRoll = ROLL_NUMERATOR;
//        curMode = MODE_INPUT;
//        curTxtLyr = curBlk = nil;
//        txtInsIdx = 0;
//        
//        baseFont = [UIFont systemFontOfSize: 20];
//        superscriptFont = [UIFont systemFontOfSize:8];
//        curFont = baseFont;
//        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: @"8"];
//        CTFontRef ctFont = CTFontCreateWithName((CFStringRef)baseFont.fontName, baseFont.pointSize, NULL);
//        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
//        CFRelease(ctFont);
//        CGSize strSize = [attStr size];
//        baseCharWidth = strSize.width;
//        baseCharHight = strSize.height;
//        attStr = [[NSMutableAttributedString alloc] initWithString: @"8"];
//        ctFont = CTFontCreateWithName((CFStringRef)superscriptFont.fontName, superscriptFont.pointSize, NULL);
//        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
//        CFRelease(ctFont);
//        strSize = [attStr size];
//        expoCharWidth = strSize.width;
//        expoCharHight = strSize.height;
//        
//        curFontW = baseCharWidth;
//        curFontH = baseCharHight;
//        
//        root = [[EquationBlock alloc] init:self];
//        root.numerTopHalf = baseCharHight / 2.0;
//        root.numerBtmHalf = baseCharHight / 2.0;
//        root.roll = ROLL_ROOT;
//        root.parent = nil;
//        curParent = root;
//        
//        NSLog(@"%s%i---%.1f-%.1f-%.1f-%.1f-", __FUNCTION__, __LINE__, baseCharWidth, baseCharHight, expoCharWidth, expoCharHight);
//        
//        [self addObserver:self forKeyPath:@"curFont" options:NSKeyValueObservingOptionNew context:nil];
//    }
//    return self;
//}

//-(id) init : (CGPoint)downLeft : (CGRect)dspFrame : (ViewController *)vc {
//    self = [super init];
//    if (self) {
//        guid_cnt = 0;
//        curRoll = ROLL_NUMERATOR;
//        curMode = MODE_INPUT;
//        curTxtLyr = curBlk = nil;
//        txtInsIdx = 0;
//        downLeftBasePoint = downLeft;
//        hasResult = NO;
//        zoomInLvl = 0;
//        
//        baseFont = [UIFont systemFontOfSize: 30];
//        superscriptFont = [UIFont systemFontOfSize:15];
//        curFont = baseFont;
//        
//        baseCharWidth = gBaseCharWidthTbl[0][8];
//        baseCharHight = baseFont.lineHeight;
//        
//        expoCharWidth = gExpoCharWidthTbl[0][8];
//        expoCharHight = superscriptFont.lineHeight;
//        
//        curFontW = baseCharWidth;
//        curFontH = baseCharHight;
//        
//        DisplayView *dspView = [[DisplayView alloc] initWithFrame:dspFrame];
//        dspView.backgroundColor = [UIColor lightGrayColor];
//        dspView.contentSize = CGSizeMake(dspFrame.size.width * 3.0, dspFrame.size.height * 3.0);
//        dspView.directionalLockEnabled = YES;
//        dspView.bounces = NO;
//        
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:vc action:@selector(handleTap:)];
//        tapGesture.numberOfTapsRequired = 1;
//        tapGesture.numberOfTouchesRequired = 1;
//        [dspView addGestureRecognizer:tapGesture];
//        
////        UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:vc action:@selector(handleDspViewSwipeRight:)];
////        right.numberOfTouchesRequired = 1;
////        right.direction = UISwipeGestureRecognizerDirectionRight;
////        [dspView addGestureRecognizer:right];
////        
////        UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:vc action:@selector(handleDspViewSwipeLeft:)];
////        left.numberOfTouchesRequired = 1;
////        left.direction = UISwipeGestureRecognizerDirectionLeft;
////        [dspView addGestureRecognizer:left];
//        
//        dspView.swipLBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//        dspView.swipLBtn.titleLabel.font = [UIFont systemFontOfSize: 30];
//        dspView.swipLBtn.showsTouchWhenHighlighted = YES;
//        [dspView.swipLBtn setTitle:@"<" forState:UIControlStateNormal];
//        dspView.swipLBtn.frame = CGRectMake(0, dspFrame.size.height / 2.0, 20, 20);
//        [dspView.swipLBtn addTarget:vc action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [dspView addSubview:dspView.swipLBtn];
//        
//        dspView.swipRBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//        dspView.swipRBtn.titleLabel.font = [UIFont systemFontOfSize: 30];
//        dspView.swipRBtn.showsTouchWhenHighlighted = YES;
//        [dspView.swipRBtn setTitle:@">" forState:UIControlStateNormal];
//        dspView.swipRBtn.frame = CGRectMake(dspFrame.size.width - 20, dspFrame.size.height / 2.0, 20, 20);
//        [dspView.swipRBtn addTarget:vc action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [dspView addSubview:dspView.swipRBtn];
//        
//        CGPoint rootPos = CGPointMake(downLeft.x, downLeft.y - baseCharHight - 1.0);
//        
//        CALayer *clayer = [CALayer layer];
//        clayer.contentsScale = [UIScreen mainScreen].scale;
//        clayer.name = @"cursorLayer";
//        clayer.hidden = NO;
//        clayer.backgroundColor = [UIColor clearColor].CGColor;
//        clayer.frame = CGRectMake(rootPos.x, rootPos.y, 3.0, baseCharHight);
//        clayer.delegate = vc;
//        [dspView.layer addSublayer:clayer];
//        
//        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"hidden"];
//        anim.fromValue = [NSNumber numberWithBool:YES];
//        anim.toValue = [NSNumber numberWithBool:NO];
//        anim.duration = 0.5;
//        anim.autoreverses = YES;
//        anim.repeatCount = HUGE_VALF;
//        [clayer addAnimation:anim forKey:nil];
//        [clayer setNeedsDisplay];
//
//        root = [[EquationBlock alloc] init:rootPos :self];
//        root.roll = ROLL_ROOT;
//        root.parent = nil;
//        root.ancestor = self;
//        curParent = root;
//
//        EquationTextLayer *layer = [[EquationTextLayer alloc] init:@"_" :rootPos :self :TEXTLAYER_EMPTY];
//        layer.parent = root;
//        root.numerFrame = layer.frame;
//        root.mainFrame = layer.frame;
//        
//        layer.c_idx = 0;
//        [root.children addObject:layer];
//        [dspView.layer addSublayer:layer];
//        curTxtLyr = layer;
//        curBlk = layer;
//
//        dspView.cursor = clayer;
//        dspView.inpOrg = clayer.frame.origin;
//        view = dspView;
//        
//        
//    }
//    return self;
//}

-(id) init : (CalcBoard *)calcB : (ViewController *)vc {
    self = [super init];
    if (self) {
        guid_cnt = 0;
        par = calcB;
        equalsign = nil;
        result = nil;
        mainFontLevel = gSettingMainFontLevel;
        
        CGPoint rootPos = CGPointMake(calcB.downLeftBasePoint.x, calcB.downLeftBasePoint.y - calcB.curFontH - 1.0);
        
        root = [[EquationBlock alloc] init:self];
        root.roll = ROLL_ROOT;
        root.parent = nil;
        root.ancestor = self;
        calcB.curParent = root;
        
        EquationTextLayer *layer = [[EquationTextLayer alloc] init:@"_" :self :TEXTLAYER_EMPTY];
        CGRect temp = layer.frame;
        temp.origin.x = rootPos.x;
        temp.origin.y = rootPos.y;
        layer.frame = temp;
        layer.mainFrame = layer.frame;
        layer.parent = root;
        root.numerFrame = layer.frame;
        root.mainFrame = layer.frame;
        
        layer.c_idx = 0;
        [root.children addObject:layer];
        [calcB.view.layer addSublayer:layer];
        calcB.curTxtLyr = layer;
        calcB.curBlk = layer;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.guid_cnt = [coder decodeIntForKey:@"guid_cnt"];
        self.root = [coder decodeObjectForKey:@"root"];
        self.equalsign = [coder decodeObjectForKey:@"equalsign"];
        self.result = [coder decodeObjectForKey:@"result"];
        self.timeRec = [coder decodeObjectForKey:@"timeRec"];
        self.separator = [coder decodeObjectForKey:@"separator"];
        self.mainFontLevel = [coder decodeIntForKey:@"mainFontLevel"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt:self.guid_cnt forKey:@"guid_cnt"];
    [coder encodeObject:self.root forKey:@"root"];
    if (self.result != nil) {
        [coder encodeObject:self.equalsign forKey:@"equalsign"];
        [coder encodeObject:self.result forKey:@"result"];
        [coder encodeObject:self.timeRec forKey:@"timeRec"];
        [coder encodeObject:self.separator forKey:@"separator"];
    }
    [coder encodeInt:self.mainFontLevel forKey:@"mainFontLevel"];
}

-(void) dumpObj : (EquationBlock *)parentBlock {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM-dd HH:mm:ss:SSS"];
    NSLog(@"%s~%@~%@~id:%i~Cidx:%lu~roll:%i~>[%.1f %.1f %.1f %.1f]>[%.1f %.1f %.1f %.1f]>[%.1f %.1f %.1f %.1f]>>>>", __FUNCTION__, [format stringFromDate:parentBlock.timeStamp], parentBlock, parentBlock.guid, (unsigned long)parentBlock.c_idx, parentBlock.roll, parentBlock.mainFrame.origin.x, parentBlock.mainFrame.origin.y, parentBlock.mainFrame.size.width, parentBlock.mainFrame.size.height, parentBlock.numerFrame.origin.x, parentBlock.numerFrame.origin.y, parentBlock.numerFrame.size.width, parentBlock.numerFrame.size.height, parentBlock.denomFrame.origin.x, parentBlock.denomFrame.origin.y, parentBlock.denomFrame.size.width, parentBlock.denomFrame.size.height);
    NSMutableArray *blockChildren = parentBlock.children;
    NSEnumerator *enumerator = [blockChildren objectEnumerator];
    id cb;
    while (cb = [enumerator nextObject]) {
        if ([cb isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *layer = cb;
            if (layer.expo != nil) {
                NSLog(@"%s~%@~%@~id:%i~Cidx:%lu~roll:%i~[%.1f %.1f %.1f %.1f]~with expo>>>>", __FUNCTION__, [format stringFromDate:layer.timeStamp], layer, layer.guid, (unsigned long)layer.c_idx, layer.roll, layer.mainFrame.origin.x, layer.mainFrame.origin.y, layer.mainFrame.size.width, layer.mainFrame.size.height);
                [self dumpObj:layer.expo];
                NSLog(@"%s~%@~%@~id:%i~<<<<<<<<<", __FUNCTION__, [format stringFromDate:layer.timeStamp], layer, layer.guid);
            } else {
                NSLog(@"%s~%@~%@~id:%i~Cidx:%lu~roll:%i~~[%.1f %.1f %.1f %.1f]~~~~~~~~", __FUNCTION__, [format stringFromDate:layer.timeStamp], layer, layer.guid, (unsigned long)layer.c_idx, layer.roll, layer.mainFrame.origin.x, layer.mainFrame.origin.y, layer.mainFrame.size.width, layer.mainFrame.size.height);
            }
        } else if ([cb isMemberOfClass: [FractionBarLayer class]]) {
            FractionBarLayer *bar = cb;
            NSLog(@"%s~%@~%@~id:%i~Cidx:%lu~%@~~~~~~~", __FUNCTION__, [format stringFromDate:bar.timeStamp], bar, bar.guid, (unsigned long)bar.c_idx, NSStringFromCGRect(bar.frame));
        } else if ([cb isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *block = cb;
            [self dumpObj:block];
        } else if ([cb isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *block = cb;
            NSLog(@"%s~%@~%@~id:%i~Cidx:%lu~roll:%i~>[%.1f %.1f %.1f %.1f]>[%.1f %.1f %.1f %.1f]>>>>", __FUNCTION__, [format stringFromDate:block.timeStamp], block, block.guid, (unsigned long)block.c_idx, block.roll, block.mainFrame.origin.x, block.mainFrame.origin.y, block.mainFrame.size.width, block.mainFrame.size.height, block.frame.origin.x, block.frame.origin.y, block.frame.size.width, block.frame.size.height);
            if (block.rootNum != nil) {
                NSLog(@"%s~%@~%@~id:%i~Cidx:%lu~roll:%i~[%.1f %.1f %.1f %.1f]~~~~~~~~", __FUNCTION__, [format stringFromDate:block.rootNum.timeStamp], block.rootNum, block.rootNum.guid, (unsigned long)block.rootNum.c_idx, block.rootNum.roll, block.rootNum.mainFrame.origin.x, block.rootNum.mainFrame.origin.y, block.rootNum.mainFrame.size.width, block.rootNum.mainFrame.size.height);
            }
            [self dumpObj:block.content];
            NSLog(@"%s~%@~%@~%i<<<<<<", __FUNCTION__, [format stringFromDate:block.timeStamp], block, block.guid);
        } else if ([cb isMemberOfClass: [WrapedEqTxtLyr class]]) {
            WrapedEqTxtLyr *wtl = cb;
            NSLog(@"%s~%@~%@~id:%i~Cidx:%lu~roll:%i~>[%.1f %.1f %.1f %.1f]>>>>>", __FUNCTION__, [format stringFromDate:wtl.timeStamp], wtl, wtl.guid, (unsigned long)wtl.c_idx, wtl.roll, wtl.mainFrame.origin.x, wtl.mainFrame.origin.y, wtl.mainFrame.size.width, wtl.mainFrame.size.height);
            [self dumpObj:wtl.content];
            NSLog(@"%s~%@~%@~%i<<<<<<", __FUNCTION__, [format stringFromDate:wtl.timeStamp], wtl, wtl.guid);
        } else if ([cb isMemberOfClass: [Parentheses class]]) {
            Parentheses *p = cb;
            if (p.expo != nil) {
                NSLog(@"%s~%@~%@~id:%i~Cidx:%lu~roll:%i~~[%.1f %.1f %.1f %.1f]~with expo>>>>", __FUNCTION__, [format stringFromDate:p.timeStamp], p, p.guid, (unsigned long)p.c_idx, p.roll, p.mainFrame.origin.x, p.mainFrame.origin.y, p.mainFrame.size.width, p.mainFrame.size.height);
                [self dumpObj:p.expo];
                NSLog(@"%s~%@~%@~id:%i~<<<<<<<<<", __FUNCTION__, [format stringFromDate:p.timeStamp], p, p.guid);
            } else {
                NSLog(@"%s~%@~%@~id:%i~Cidx:%lu~roll:%i~~[%.1f %.1f %.1f %.1f]~~~~~~~~", __FUNCTION__, [format stringFromDate:p.timeStamp], p, p.guid, (unsigned long)p.c_idx, p.roll, p.mainFrame.origin.x, p.mainFrame.origin.y, p.mainFrame.size.width, p.mainFrame.size.height);
            }
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
    }
    NSLog(@"%s~%@~%@~%i<<<<<<", __FUNCTION__, [format stringFromDate:parentBlock.timeStamp], parentBlock, parentBlock.guid);
}

-(void) dumpEverything : (EquationBlock *)eb {
    [self dumpObj:eb];
    NSLog(@"%s>~%@~%@~%@~%i~%lu~%i~%@~~~~", __FUNCTION__, self.par.curParent, self.par.curBlk, self.par.curTxtLyr, self.par.curMode, (unsigned long)self.par.insertCIdx, self.par.txtInsIdx, self.result);
}

-(id) lookForElementByPoint : (EquationBlock *)rootB : (CGPoint) point {
    
    if (!CGRectContainsPoint(rootB.mainFrame, point)) {
        if (self.result != nil && CGRectContainsPoint(self.result.frame, point) && isNumber([self.result.string string])) {
            return self.result;
        } else {
            return nil;
        }
    }
    
    if (rootB.bar != nil && CGRectContainsPoint(rootB.bar.frame, point)) {
        return rootB;
    }
    
    for (id child in rootB.children) {
        if ([child isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *eB = child;
            if (CGRectContainsPoint(eB.mainFrame, point)) {
                return [self lookForElementByPoint :eB :point];
            }
        } else if ([child isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *layer = child;
            EquationBlock *expo = layer.expo;
            if (layer.expo != nil) {
                if (CGRectContainsPoint(layer.mainFrame, point)) { // In the main frame
                    if (CGRectContainsPoint(expo.mainFrame, point)) { // In expo
                        return [self lookForElementByPoint :expo :point];
                    } else { // In base or blank
                        return layer;
                    }
                }
            } else {
                if (CGRectContainsPoint(layer.mainFrame, point)) { // In the main frame
                    return layer;
                }
            }
        } else if ([child isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *rB = child;
            if (CGRectContainsPoint(rB.mainFrame, point)) {
                EquationBlock *eb = rB.content;
                if (CGRectContainsPoint(eb.mainFrame, point)) {
                    return [self lookForElementByPoint :eb :point];
                } else {
                    return rB;
                }
            }
        } else if ([child isMemberOfClass: [FractionBarLayer class]]) {
            continue;
        } else if ([child isMemberOfClass: [WrapedEqTxtLyr class]]) {
            WrapedEqTxtLyr *wtl = child;
            if (CGRectContainsPoint(wtl.mainFrame, point)) {
                EquationBlock *eb = wtl.content;
                if (CGRectContainsPoint(eb.mainFrame, point)) {
                    return [self lookForElementByPoint :eb :point];
                } else {
                    return wtl;
                }
            }
        } else if ([child isMemberOfClass: [Parentheses class]]) {
            Parentheses *p = child;
            EquationBlock *expo = p.expo;
            if (p.expo != nil) {
                if (CGRectContainsPoint(p.mainFrame, point)) { // In the main frame
                    if (CGRectContainsPoint(expo.mainFrame, point)) { // In expo
                        return [self lookForElementByPoint :expo :point];
                    } else { // In base or blank
                        return p;
                    }
                }
            } else {
                if (CGRectContainsPoint(p.mainFrame, point)) { // In the main frame
                    return p;
                }
            }
        } else
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    
    return rootB;
}

-(void)removeElement:(id)blk {
    CalcBoard *calcB = self.par;
    
    if ([blk isMemberOfClass: [EquationBlock class]]) {
        EquationBlock *eb = blk;
        
        CGFloat fontH = gCharHeightTbl[gSettingMainFontLevel][eb.fontLvl];
        
        if (eb.roll == ROLL_ROOT) {
            CGPoint p = CGPointMake(eb.mainFrame.origin.x, eb.mainFrame.origin.y + eb.mainFrame.size.height - fontH);
            EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :self :TEXTLAYER_EMPTY];
            CGRect temp = l.frame;
            temp.origin.x = p.x;
            temp.origin.y = p.y;
            l.frame = temp;
            l.mainFrame = l.frame;
            l.roll = ROLL_NUMERATOR;
            l.parent = eb;
            l.c_idx = 0;
            [eb destroy];
            [eb.children removeAllObjects];
            [eb.children addObject:l];
            [calcB.view.layer addSublayer: l];
            eb.mainFrame = eb.numerFrame = l.frame;
            eb.denomFrame = CGRectMake(0, 0, 0, 0);
            eb.numerTopHalf = eb.numerBtmHalf = l.frame.size.height / 2.0;
            eb.denomTopHalf = eb.denomBtmHalf = 0.0;
            
            cfgEqnBySlctBlk(self, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
        } else if (eb.roll == ROLL_ROOT_ROOT) {
            RadicalBlock *rb = eb.parent;
            CGFloat orgWidth = rb.frame.size.width;
            CGPoint p = CGPointMake(eb.mainFrame.origin.x, eb.mainFrame.origin.y + eb.mainFrame.size.height - fontH);
            EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :self :TEXTLAYER_EMPTY];
            CGRect temp = l.frame;
            temp.origin.x = p.x;
            temp.origin.y = p.y;
            l.frame = temp;
            l.mainFrame = l.frame;
            l.roll = ROLL_NUMERATOR;
            l.parent = eb;
            l.c_idx = 0;
            [eb destroy];
            [eb.children removeAllObjects];
            [eb.children addObject:l];
            [calcB.view.layer addSublayer: l];
            eb.mainFrame = eb.numerFrame = l.frame;
            eb.denomFrame = CGRectMake(0, 0, 0, 0);
            eb.numerTopHalf = eb.numerBtmHalf = l.frame.size.height / 2.0;
            eb.denomTopHalf = eb.denomBtmHalf = 0.0;
            
            [rb updateFrame];
            [rb setNeedsDisplay];
            
            [rb.parent updateFrameWidth:rb.frame.size.width - orgWidth :rb.roll];
            [rb.parent updateFrameHeightS1:rb];
            [self.root adjustElementPosition];
            
            cfgEqnBySlctBlk(self, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
        } else if (eb.roll == ROLL_EXPO_ROOT) {
            EquationTextLayer *parLayer = eb.parent;
            CGFloat orgWidth = parLayer.mainFrame.size.width;
            CGPoint p = CGPointMake(eb.mainFrame.origin.x, eb.mainFrame.origin.y + eb.mainFrame.size.height - fontH);
            EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :self :TEXTLAYER_EMPTY];
            CGRect temp = l.frame;
            temp.origin.x = p.x;
            temp.origin.y = p.y;
            l.frame = temp;
            l.mainFrame = l.frame;
            l.roll = ROLL_NUMERATOR;
            l.parent = eb;
            l.c_idx = 0;
            [eb destroy];
            [eb.children removeAllObjects];
            [eb.children addObject:l];
            [calcB.view.layer addSublayer: l];
            eb.mainFrame = eb.numerFrame = l.frame;
            eb.denomFrame = CGRectMake(0, 0, 0, 0);
            eb.numerTopHalf = eb.numerBtmHalf = l.frame.size.height / 2.0;
            eb.denomTopHalf = eb.denomBtmHalf = 0.0;
            
            [parLayer updateFrameBaseOnExpo];
            
            [parLayer.parent updateFrameWidth:parLayer.mainFrame.size.width - orgWidth :parLayer.roll];
            [parLayer.parent updateFrameHeightS1:parLayer];
            [self.root adjustElementPosition];
            
            cfgEqnBySlctBlk(self, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
        } else if (eb.roll == ROLL_WRAP_ROOT) {
            // To be done
        } else if ([eb.parent isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *parent = eb.parent;
            CGFloat orgWidth = eb.mainFrame.size.width;
            if (parent.children.count == 1) {
                CGPoint p = CGPointMake(eb.mainFrame.origin.x, eb.mainFrame.origin.y + eb.mainFrame.size.height - fontH);
                EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :self :TEXTLAYER_EMPTY];
                CGRect temp = l.frame;
                temp.origin.x = p.x;
                temp.origin.y = p.y;
                l.frame = temp;
                l.mainFrame = l.frame;
                l.roll = ROLL_NUMERATOR;
                l.parent = parent;
                l.c_idx = 0;
                [eb destroy];
                [parent.children removeObjectAtIndex:0];
                [parent.children addObject:l];
                [calcB.view.layer addSublayer: l];
                
                [parent updateFrameWidth:l.frame.size.width - orgWidth :l.roll];
                [parent updateFrameHeightS1:l];
                [self.root adjustElementPosition];
                
                cfgEqnBySlctBlk(self, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
            } else {
                if (eb.c_idx == parent.children.count - 1 && [[parent.children objectAtIndex:eb.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                    /* Case:  @ @
                              ---
                               *  */
                    CGPoint p = CGPointMake(eb.mainFrame.origin.x, eb.mainFrame.origin.y + eb.mainFrame.size.height - fontH);
                    EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :self :TEXTLAYER_EMPTY];
                    CGRect temp = l.frame;
                    temp.origin.x = p.x;
                    temp.origin.y = p.y;
                    l.frame = temp;
                    l.mainFrame = l.frame;
                    l.roll = eb.roll;
                    l.parent = parent;
                    l.c_idx = eb.c_idx;
                    [eb destroy];
                    [parent.children removeLastObject];
                    [parent.children addObject:l];
                    [calcB.view.layer addSublayer:l];
                    
                    [parent updateFrameWidth:l.frame.size.width - orgWidth :l.roll];
                    [parent updateFrameHeightS1:l];
                    [self.root adjustElementPosition];
                    
                    cfgEqnBySlctBlk(self, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
                } else if(eb.c_idx == 0 && [[parent.children objectAtIndex:eb.c_idx + 1] isMemberOfClass:[FractionBarLayer class]]) {
                    /* Case:  *
                             ---
                             @ @ */
                    CGPoint p = CGPointMake(eb.mainFrame.origin.x, eb.mainFrame.origin.y + eb.mainFrame.size.height - fontH);
                    EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :self :TEXTLAYER_EMPTY];
                    CGRect temp = l.frame;
                    temp.origin.x = p.x;
                    temp.origin.y = p.y;
                    l.frame = temp;
                    l.mainFrame = l.frame;
                    l.roll = eb.roll;
                    l.parent = parent;
                    l.c_idx = 0;
                    [eb destroy];
                    [parent.children removeObjectAtIndex:0];
                    [parent.children insertObject:l atIndex:0];
                    [calcB.view.layer addSublayer: l];
                    
                    [parent updateFrameWidth:l.frame.size.width - orgWidth :l.roll];
                    [parent updateFrameHeightS1:l];
                    [self.root adjustElementPosition];
                    
                    cfgEqnBySlctBlk(self, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
                } else {
                    /* Case:  @ @
                              ---
                              @ @ */
                    
                    if (eb.c_idx == 0) {
                        [eb destroy];
                        [parent.children removeObjectAtIndex:0];
                        [parent updateCIdx];
                        
                        [parent updateFrameWidth:-orgWidth :eb.roll];
                        [parent updateFrameHeightS1:[parent.children objectAtIndex:0]];
                        [self.root adjustElementPosition];
                        
                        id b = parent.children.firstObject;
                        if ([b isMemberOfClass:[EquationBlock class]]) {
                            EquationBlock *eb1 = b;
                            calcB.view.cursor.frame = CGRectMake(eb1.mainFrame.origin.x, eb1.mainFrame.origin.y, CURSOR_W, eb1.mainFrame.size.height);
                            calcB.curTxtLyr = nil;
                            calcB.curRoll = eb1.roll;
                        } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                            EquationTextLayer *l = b;
                            calcB.view.cursor.frame = CGRectMake(l.frame.origin.x, l.frame.origin.y, CURSOR_W, l.frame.size.height);
                            calcB.curTxtLyr = l;
                            calcB.curRoll = l.roll;
                            calcB.txtInsIdx = 0;
                        } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                            RadicalBlock *rb1 = b;
                            calcB.view.cursor.frame = CGRectMake(rb1.frame.origin.x, rb1.frame.origin.y, CURSOR_W, rb1.frame.size.height);
                            calcB.curTxtLyr = nil;
                            calcB.curRoll = rb1.roll;
                        } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                            WrapedEqTxtLyr *wetl = b;
                            calcB.view.cursor.frame = CGRectMake(wetl.mainFrame.origin.x, wetl.mainFrame.origin.y, CURSOR_W, wetl.mainFrame.size.height);
                            calcB.curTxtLyr = nil;
                            calcB.curRoll = wetl.roll;
                        } else if ([b isMemberOfClass:[Parentheses class]]) {
                            Parentheses *p = b;
                            calcB.view.cursor.frame = CGRectMake(p.frame.origin.x, p.frame.origin.y, CURSOR_W, p.frame.size.height);
                            calcB.curTxtLyr = nil;
                            calcB.curRoll = p.roll;
                        } else {
                            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                            return;
                        }
                        calcB.curMode = MODE_INSERT;
                        calcB.insertCIdx = 0;
                        calcB.curParent = parent;
                        calcB.curBlk = b;
                    } else if ([[parent.children objectAtIndex:eb.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                        [eb destroy];
                        [parent.children removeObjectAtIndex:eb.c_idx];
                        [parent updateCIdx];
                        
                        [parent updateFrameWidth:-orgWidth :eb.roll];
                        [parent updateFrameHeightS1:[parent.children objectAtIndex:eb.c_idx]];
                        [self.root adjustElementPosition];
                        
                        id b = [parent.children objectAtIndex:eb.c_idx];
                        if ([b isMemberOfClass:[EquationBlock class]]) {
                            EquationBlock *eb1 = b;
                            calcB.view.cursor.frame = CGRectMake(eb1.mainFrame.origin.x, eb1.mainFrame.origin.y, CURSOR_W, eb1.mainFrame.size.height);
                            calcB.curTxtLyr = nil;
                            calcB.curRoll = eb1.roll;
                        } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                            EquationTextLayer *l = b;
                            calcB.view.cursor.frame = CGRectMake(l.frame.origin.x, l.frame.origin.y, CURSOR_W, l.frame.size.height);
                            calcB.curTxtLyr = l;
                            calcB.curRoll = l.roll;
                            calcB.txtInsIdx = 0;
                        } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                            RadicalBlock *rb1 = b;
                            calcB.view.cursor.frame = CGRectMake(rb1.frame.origin.x, rb1.frame.origin.y, CURSOR_W, rb1.frame.size.height);
                            calcB.curTxtLyr = nil;
                            calcB.curRoll = rb1.roll;
                        } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                            WrapedEqTxtLyr *wetl = b;
                            calcB.view.cursor.frame = CGRectMake(wetl.mainFrame.origin.x, wetl.mainFrame.origin.y, CURSOR_W, wetl.mainFrame.size.height);
                            calcB.curTxtLyr = nil;
                            calcB.curRoll = wetl.roll;
                        } else if ([b isMemberOfClass:[Parentheses class]]) {
                            Parentheses *p = b;
                            calcB.view.cursor.frame = CGRectMake(p.frame.origin.x, p.frame.origin.y, CURSOR_W, p.frame.size.height);
                            calcB.curTxtLyr = nil;
                            calcB.curRoll = p.roll;
                        } else {
                            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                            return;
                        }
                        calcB.curMode = MODE_INSERT;
                        calcB.insertCIdx = eb.c_idx;
                        calcB.curParent = parent;
                        calcB.curBlk = b;
                    } else {
                        [eb destroy];
                        [parent.children removeObjectAtIndex:eb.c_idx];
                        [parent updateCIdx];
                        
                        id b = [parent.children objectAtIndex:eb.c_idx - 1];
                        [parent updateFrameWidth:-orgWidth :eb.roll];
                        [parent updateFrameHeightS1:b];
                        [self.root adjustElementPosition];
                        
                        if ([b isMemberOfClass:[EquationBlock class]]) {
                            EquationBlock *eb = b;
                            if (eb.bar != nil) {
                                cfgEqnBySlctBlk(self, eb, CGPointMake(eb.bar.frame.origin.x + eb.bar.frame.size.width - 1.0, eb.bar.frame.origin.y + 1.0));
                            } else {
                                cfgEqnBySlctBlk(self, eb, CGPointMake(eb.mainFrame.origin.x + eb.mainFrame.size.width - 1.0, eb.mainFrame.origin.y + eb.mainFrame.size.height - 1.0));
                            }
                        } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                            EquationTextLayer *l = b;
                            cfgEqnBySlctBlk(self, l, CGPointMake(l.mainFrame.origin.x + l.mainFrame.size.width - 1.0, l.mainFrame.origin.y + 1.0));
                        } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                            RadicalBlock *rb = b;
                            cfgEqnBySlctBlk(self, rb, CGPointMake(rb.frame.origin.x + rb.frame.size.width - 0.5, rb.frame.origin.y + 0.5));
                        } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                            WrapedEqTxtLyr *wetl = b;
                            cfgEqnBySlctBlk(self, wetl, CGPointMake(wetl.mainFrame.origin.x + wetl.mainFrame.size.width - 1.0, wetl.mainFrame.origin.y + 1.0));
                        } else if ([b isMemberOfClass:[Parentheses class]]) {
                            Parentheses *p = b;
                            cfgEqnBySlctBlk(self, p, CGPointMake(p.mainFrame.origin.x + p.mainFrame.size.width - 0.5, p.mainFrame.origin.y + 0.5));
                        } else {
                            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                        }
                    }
                }
            }
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return;
        }
    } else if ([blk isMemberOfClass: [EquationTextLayer class]]) {
        EquationTextLayer *l = blk;
        CGFloat orgWidth = l.mainFrame.size.width;
        
        if ([l.parent isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *rb = l.parent;
            if (l.type == TEXTLAYER_EMPTY) {
                [l destroy];
                rb.rootNum = nil;
                cfgEqnBySlctBlk(self, rb, CGPointMake(rb.mainFrame.origin.x + 1.0, rb.mainFrame.origin.y + 1.0));
            } else {
                CGPoint p = CGPointMake(l.frame.origin.x, l.frame.origin.y);
                EquationTextLayer *el = [[EquationTextLayer alloc] init:@"_" :self :TEXTLAYER_EMPTY];
                CGRect temp = el.frame;
                temp.origin = p;
                el.mainFrame = el.frame = temp;
                el.roll = ROLL_ROOT_NUM;
                el.parent = rb;
                el.c_idx = 0;
                [l destroy];
                rb.rootNum = el;
                [calcB.view.layer addSublayer: el];
                
                [rb updateFrameWidth:el.frame.size.width - orgWidth :el.roll];
                [self.root adjustElementPosition];
                
                cfgEqnBySlctBlk(self, el, CGPointMake(el.frame.origin.x + 1.0, el.frame.origin.y + 1.0));
            }
            return;
        }
        
        EquationBlock *parent = l.parent;
        CGFloat fontH = gCharHeightTbl[gSettingMainFontLevel][l.fontLvl];
        
        if (parent.children.count == 1) {
            if (l.type == TEXTLAYER_EMPTY) {
                if (parent.roll == ROLL_ROOT) {
                    if (l.expo != nil) {
                        [l.expo destroy];
                        l.expo = nil;
                        [l updateFrameBaseOnBase];
                        
                        parent.mainFrame = parent.numerFrame = l.frame;
                        parent.denomFrame = CGRectMake(0, 0, 0, 0);
                        parent.numerTopHalf = parent.numerBtmHalf = l.frame.size.height / 2.0;
                        parent.denomTopHalf = parent.denomBtmHalf = 0.0;
                    }
                } else if (parent.roll == ROLL_ROOT_ROOT) {
                    [self removeElement:parent.parent];
                } else if (parent.roll == ROLL_EXPO_ROOT) {
                    EquationTextLayer *parLayer = parent.parent;
                    [parent destroy];
                    parLayer.expo = nil;
                    [parLayer updateFrameBaseOnBase];
                    [parLayer.parent updateFrameWidth:-orgWidth :parLayer.roll];
                    [parLayer.parent updateFrameHeightS1:parLayer];
                    [self.root adjustElementPosition];
                    cfgEqnBySlctBlk(self, parLayer, CGPointMake(parLayer.frame.origin.x + parLayer.frame.size.width - 1.0, parLayer.frame.origin.y + 1.0));
                } else if (parent.roll == ROLL_WRAP_ROOT) {
                    [self removeElement:parent.parent];
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
            } else {
                CGPoint p = CGPointMake(l.frame.origin.x, l.frame.origin.y);
                EquationTextLayer *el = [[EquationTextLayer alloc] init:@"_" :self :TEXTLAYER_EMPTY];
                CGRect temp = el.frame;
                temp.origin.x = p.x;
                temp.origin.y = p.y;
                el.frame = temp;
                el.mainFrame = el.frame;
                el.roll = l.roll;
                el.parent = parent;
                el.c_idx = 0;
                [l destroy];
                [parent.children removeAllObjects];
                [parent.children addObject:el];
                [calcB.view.layer addSublayer: el];
                
                [parent updateFrameWidth:el.frame.size.width - orgWidth :el.roll];
                [parent updateFrameHeightS1:el];
                [self.root adjustElementPosition];
                
                cfgEqnBySlctBlk(self, el, CGPointMake(el.frame.origin.x + 1.0, el.frame.origin.y + 1.0));
            }
        } else {
            if (l.c_idx == parent.children.count - 1 && [[parent.children objectAtIndex:l.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                /* Case:  @ @
                          ---
                           *  */
                if (l.type == TEXTLAYER_EMPTY) {
                    /* Remove empty layer */
                    [l destroy];
                    [parent.children removeLastObject];
                    /* Remove fraction bar */
                    [parent.bar destroy];
                    [parent.children removeLastObject];
                    parent.bar = nil;
                    /* Remove denom */
                    if (parent.roll == ROLL_ROOT || parent.roll == ROLL_ROOT_ROOT || parent.roll == ROLL_EXPO_ROOT || parent.roll == ROLL_WRAP_ROOT) { // Just move down numer
                        parent.numerFrame = CGRectOffset(parent.numerFrame, 0.0, fontH);
                        parent.denomFrame = CGRectMake(0, 0, 0, 0);
                        parent.mainFrame = parent.numerFrame;
                        if (parent.roll == ROLL_ROOT_ROOT) {
                            RadicalBlock *rb = parent.parent;
                            CGFloat orgW = rb.frame.size.width;
                            [rb updateFrame];
                            [rb setNeedsDisplay];
                            [rb.parent updateFrameWidth:rb.frame.size.width - orgW :rb.roll];
                            [rb.parent updateFrameHeightS1:rb];
                        } else if (parent.roll == ROLL_EXPO_ROOT) {
                            EquationTextLayer *parLayer = parent.parent;
                            [parLayer updateFrameBaseOnExpo];
                            [parLayer.parent updateFrameHeightS1:parLayer];
                        } else if (parent.roll == ROLL_WRAP_ROOT) {
                            WrapedEqTxtLyr *wetl = parent.parent;
                            CGFloat orgW = wetl.mainFrame.size.width;
                            
                            [wetl updateFrame:YES];
                            
                            if ([wetl.parent isMemberOfClass:[EquationBlock class]]) {
                                [(EquationBlock *)wetl.parent updateFrameHeightS1:wetl];
                                [(EquationBlock *)wetl.parent updateFrameWidth:wetl.mainFrame.size.width - orgW :wetl.roll];
                            } else {
                                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                            }
                        }
                        [self.root adjustElementPosition];
                        id b = [parent.children lastObject];
                        if ([b isMemberOfClass:[EquationBlock class]]) {
                            EquationBlock *eb = b;
                            if (eb.bar != nil) {
                                cfgEqnBySlctBlk(self, eb, CGPointMake(eb.bar.frame.origin.x + eb.bar.frame.size.width - 1.0, eb.bar.frame.origin.y + 1.0));
                            } else {
                                cfgEqnBySlctBlk(self, eb, CGPointMake(eb.mainFrame.origin.x + eb.mainFrame.size.width - 1.0, eb.mainFrame.origin.y + eb.mainFrame.size.height - 1.0));
                            }
                        } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                            EquationTextLayer *l = b;
                            cfgEqnBySlctBlk(self, l, CGPointMake(l.mainFrame.origin.x + l.mainFrame.size.width - 1.0, l.mainFrame.origin.y + 1.0));
                        } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                            RadicalBlock *rb = b;
                            cfgEqnBySlctBlk(self, rb, CGPointMake(rb.frame.origin.x + rb.frame.size.width - 0.5, rb.frame.origin.y + 0.5));
                        } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                            WrapedEqTxtLyr *l = b;
                            cfgEqnBySlctBlk(self, l, CGPointMake(l.mainFrame.origin.x + l.mainFrame.size.width - 1.0, l.mainFrame.origin.y + 1.0));
                        } else if ([b isMemberOfClass:[Parentheses class]]) {
                            Parentheses *p = b;
                            cfgEqnBySlctBlk(self, p, CGPointMake(p.mainFrame.origin.x + p.mainFrame.size.width - 0.5, p.mainFrame.origin.y + 0.5));
                        } else {
                            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                        }
                    } else { // Degrade e block
                        EquationBlock *eb = parent.parent;
                        int cnt = 1;
                        int r = ROLL_NUMERATOR;
                        if (eb.bar != nil) {
                            if (parent.c_idx < eb.bar.c_idx) {
                                r = ROLL_NUMERATOR;
                            } else {
                                r = ROLL_DENOMINATOR;
                            }
                        }
                        for (id b in parent.children) {
                            if ([b isMemberOfClass:[EquationBlock class]]) {
                                ((EquationBlock *)b).roll = r;
                                ((EquationBlock *)b).parent = eb;
                            } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                                ((EquationTextLayer *)b).roll = r;
                                ((EquationTextLayer *)b).parent = eb;
                            } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                                ((RadicalBlock *)b).roll = r;
                                ((RadicalBlock *)b).parent = eb;
                            } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                                ((WrapedEqTxtLyr *)b).roll = r;
                                ((WrapedEqTxtLyr *)b).parent = eb;
                            } else if ([b isMemberOfClass:[Parentheses class]]) {
                                ((Parentheses *)b).roll = r;
                                ((Parentheses *)b).parent = eb;
                            } else {
                                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                            }
                            [eb.children insertObject:b atIndex:parent.c_idx + cnt++];
                        }
                        
                        [eb.children removeObjectAtIndex:parent.c_idx];
                        [eb updateCIdx];
                        
                        [parent.children removeAllObjects];
                        parent.children = nil;
                        
                        id b = [eb.children objectAtIndex:parent.c_idx + cnt - 2];
                        [eb updateFrameHeightS1:b];
                        [self.root adjustElementPosition];
                        if ([b isMemberOfClass:[EquationBlock class]]) {
                            EquationBlock *eb = b;
                            if (eb.bar != nil) {
                                cfgEqnBySlctBlk(self, eb, CGPointMake(eb.bar.frame.origin.x + eb.bar.frame.size.width - 1.0, eb.bar.frame.origin.y + 1.0));
                            } else {
                                cfgEqnBySlctBlk(self, eb, CGPointMake(eb.mainFrame.origin.x + eb.mainFrame.size.width - 1.0, eb.mainFrame.origin.y + eb.mainFrame.size.height - 1.0));
                            }
                        } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                            EquationTextLayer *l = b;
                            cfgEqnBySlctBlk(self, l, CGPointMake(l.mainFrame.origin.x + l.mainFrame.size.width - 1.0, l.mainFrame.origin.y + 1.0));
                        } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                            RadicalBlock *rb = b;
                            cfgEqnBySlctBlk(self, rb, CGPointMake(rb.frame.origin.x + rb.frame.size.width - 0.5, rb.frame.origin.y + 0.5));
                        } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                            WrapedEqTxtLyr *l = b;
                            cfgEqnBySlctBlk(self, l, CGPointMake(l.mainFrame.origin.x + l.mainFrame.size.width - 1.0, l.mainFrame.origin.y + 1.0));
                        } else if ([b isMemberOfClass:[Parentheses class]]) {
                            Parentheses *p = b;
                            cfgEqnBySlctBlk(self, p, CGPointMake(p.mainFrame.origin.x + p.mainFrame.size.width - 0.5, p.mainFrame.origin.y + 0.5));
                        } else {
                            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                        }
                    }
                } else {
                    CGPoint p = CGPointMake(l.frame.origin.x, l.frame.origin.y);
                    EquationTextLayer *el = [[EquationTextLayer alloc] init:@"_" :self :TEXTLAYER_EMPTY];
                    CGRect temp = el.frame;
                    temp.origin.x = p.x;
                    temp.origin.y = p.y;
                    el.frame = temp;
                    el.mainFrame = el.frame;
                    el.roll = l.roll;
                    el.parent = parent;
                    el.c_idx = l.c_idx;
                    [l destroy];
                    [parent.children removeLastObject];
                    [parent.children addObject:el];
                    [calcB.view.layer addSublayer: el];
                    
                    [parent updateFrameWidth:el.frame.size.width - orgWidth :el.roll];
                    [parent updateFrameHeightS1:el];
                    [self.root adjustElementPosition];
                    
                    cfgEqnBySlctBlk(self, el, CGPointMake(el.frame.origin.x + 1.0, el.frame.origin.y + 1.0));
                }
            } else if(l.c_idx == 0 && [[parent.children objectAtIndex:l.c_idx + 1] isMemberOfClass:[FractionBarLayer class]]) {
                /* Case:  *
                         ---
                         @ @ */
                if (l.type == TEXTLAYER_EMPTY) {
                    if (parent.roll == ROLL_ROOT) {
                        return;  // Do nothing
                    } else {
                        id pre = getPrevBlk(self, l);
                        if (pre != nil) {
                            if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                                EquationTextLayer *layer = pre;
                                if (layer.fontLvl == l.fontLvl) {
                                    (void)locaLastLyr(self, pre);
                                } else { //Switch from expo to base in a same text layer
                                    calcB.curTxtLyr = layer;
                                    calcB.curBlk = layer;
                                    calcB.curParent = layer.parent;
                                    calcB.curRoll = layer.roll;
                                    calcB.curMode = MODE_INSERT;
                                    calcB.insertCIdx = layer.c_idx + 1;
                                    calcB.txtInsIdx = (int)layer.strLenTbl.count - 1;
                                    [calcB updateFontInfo:layer.fontLvl :gSettingMainFontLevel];                                    
                                    calcB.view.cursor.frame = CGRectMake(layer.frame.origin.x + layer.frame.size.width, layer.frame.origin.y, CURSOR_W, fontH);
                                }
                            } else {
                                (void)locaLastLyr(self, pre);
                            }
                        } else {
                            return;
                        }
                    }
                    
                } else {
                    CGPoint p = CGPointMake(l.frame.origin.x, l.frame.origin.y);
                    EquationTextLayer *el = [[EquationTextLayer alloc] init:@"_" :self :TEXTLAYER_EMPTY];
                    CGRect temp = el.frame;
                    temp.origin.x = p.x;
                    temp.origin.y = p.y;
                    el.frame = temp;
                    el.mainFrame = el.frame;
                    el.roll = l.roll;
                    el.parent = parent;
                    el.c_idx = l.c_idx;
                    [l destroy];
                    [parent.children removeObjectAtIndex:0];
                    [parent.children insertObject:el atIndex:0];
                    [calcB.view.layer addSublayer: el];
                    
                    [parent updateFrameWidth:el.frame.size.width - orgWidth :el.roll];
                    [parent updateFrameHeightS1:el];
                    [self.root adjustElementPosition];
                    
                    cfgEqnBySlctBlk(self, el, CGPointMake(el.frame.origin.x + 1.0, el.frame.origin.y + 1.0));
                }
            } else {
                /* Case:  @ @
                          ---
                          @ @ */
                if (l.c_idx == 0) {
                    [l destroy];
                    [parent.children removeObjectAtIndex:0];
                    [parent updateCIdx];
                    
                    [parent updateFrameWidth:-orgWidth :l.roll];
                    [parent updateFrameHeightS1:[parent.children objectAtIndex:0]];
                    [self.root adjustElementPosition];
                    
                    id b = parent.children.firstObject;
                    if ([b isMemberOfClass:[EquationBlock class]]) {
                        EquationBlock *eb1 = b;
                        calcB.view.cursor.frame = CGRectMake(eb1.mainFrame.origin.x, eb1.mainFrame.origin.y, CURSOR_W, eb1.mainFrame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = eb1.roll;
                    } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        calcB.view.cursor.frame = CGRectMake(l.frame.origin.x, l.frame.origin.y, CURSOR_W, l.frame.size.height);
                        if (l.type == TEXTLAYER_EMPTY || l.type == TEXTLAYER_NUM) {
                            calcB.curTxtLyr = l;
                        } else {
                            calcB.curTxtLyr = nil;
                        }
                        calcB.txtInsIdx = 0;
                        calcB.curRoll = l.roll;
                    } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                        RadicalBlock *rb1 = b;
                        calcB.view.cursor.frame = CGRectMake(rb1.frame.origin.x, rb1.frame.origin.y, CURSOR_W, rb1.frame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = rb1.roll;
                    } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                        WrapedEqTxtLyr *wetl = b;
                        calcB.view.cursor.frame = CGRectMake(wetl.mainFrame.origin.x, wetl.mainFrame.origin.y, CURSOR_W, wetl.mainFrame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = wetl.roll;
                    } else if ([b isMemberOfClass:[Parentheses class]]) {
                        Parentheses *p = b;
                        calcB.view.cursor.frame = CGRectMake(p.frame.origin.x, p.frame.origin.y, CURSOR_W, p.frame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = p.roll;
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                        return;
                    }
                    calcB.curMode = MODE_INSERT;
                    calcB.insertCIdx = 0;
                    calcB.curParent = parent;
                    calcB.curBlk = b;
                } else if ([[parent.children objectAtIndex:l.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                    [l destroy];
                    [parent.children removeObjectAtIndex:l.c_idx];
                    [parent updateCIdx];
                    
                    [parent updateFrameWidth:-orgWidth :l.roll];
                    [parent updateFrameHeightS1:[parent.children objectAtIndex:l.c_idx]];
                    [self.root adjustElementPosition];
                    
                    id b = [parent.children objectAtIndex:l.c_idx];
                    if ([b isMemberOfClass:[EquationBlock class]]) {
                        EquationBlock *eb1 = b;
                        calcB.view.cursor.frame = CGRectMake(eb1.mainFrame.origin.x, eb1.mainFrame.origin.y, CURSOR_W, eb1.mainFrame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = eb1.roll;
                    } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        calcB.view.cursor.frame = CGRectMake(l.frame.origin.x, l.frame.origin.y, CURSOR_W, l.frame.size.height);
                        calcB.curTxtLyr = l;
                        calcB.curRoll = l.roll;
                        calcB.txtInsIdx = 0;
                    } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                        RadicalBlock *rb1 = b;
                        calcB.view.cursor.frame = CGRectMake(rb1.frame.origin.x, rb1.frame.origin.y, CURSOR_W, rb1.frame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = rb1.roll;
                    } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                        WrapedEqTxtLyr *wetl = b;
                        calcB.view.cursor.frame = CGRectMake(wetl.mainFrame.origin.x, wetl.mainFrame.origin.y, CURSOR_W, wetl.mainFrame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = wetl.roll;
                    } else if ([b isMemberOfClass:[Parentheses class]]) {
                        Parentheses *p = b;
                        calcB.view.cursor.frame = CGRectMake(p.frame.origin.x, p.frame.origin.y, CURSOR_W, p.frame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = p.roll;
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                        return;
                    }
                    calcB.curMode = MODE_INSERT;
                    calcB.insertCIdx = l.c_idx;
                    calcB.curParent = parent;
                    calcB.curBlk = b;
                } else {
                    [l destroy];
                    [parent.children removeObjectAtIndex:l.c_idx];
                    [parent updateCIdx];
                    
                    id b = [parent.children objectAtIndex:l.c_idx - 1];
                    [parent updateFrameWidth:-orgWidth :l.roll];
                    [parent updateFrameHeightS1:b];
                    [self.root adjustElementPosition];
                    
                    if ([b isMemberOfClass:[EquationBlock class]]) {
                        EquationBlock *eb = b;
                        if (eb.bar != nil) {
                            cfgEqnBySlctBlk(self, eb, CGPointMake(eb.bar.frame.origin.x + eb.bar.frame.size.width - 1.0, eb.bar.frame.origin.y + 1.0));
                        } else {
                            cfgEqnBySlctBlk(self, eb, CGPointMake(eb.mainFrame.origin.x + eb.mainFrame.size.width - 1.0, eb.mainFrame.origin.y + eb.mainFrame.size.height - 1.0));
                        }
                    } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        cfgEqnBySlctBlk(self, l, CGPointMake(l.mainFrame.origin.x + l.mainFrame.size.width - 1.0, l.mainFrame.origin.y + 1.0));
                    } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                        RadicalBlock *rb = b;
                        cfgEqnBySlctBlk(self, rb, CGPointMake(rb.frame.origin.x + rb.frame.size.width - 0.5, rb.frame.origin.y + 0.5));
                    } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                        WrapedEqTxtLyr *l = b;
                        cfgEqnBySlctBlk(self, l, CGPointMake(l.mainFrame.origin.x + l.mainFrame.size.width - 1.0, l.mainFrame.origin.y + 1.0));
                    } else if ([b isMemberOfClass:[Parentheses class]]) {
                        Parentheses *p = b;
                        cfgEqnBySlctBlk(self, p, CGPointMake(p.mainFrame.origin.x + p.mainFrame.size.width - 0.5, p.mainFrame.origin.y + 0.5));
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                }
            }
        }
    } else if ([blk isMemberOfClass: [RadicalBlock class]]) {
        RadicalBlock *rb = blk;
        if (![rb.parent isMemberOfClass: [EquationBlock class]]) {
            return;
        }
        EquationBlock *parent = rb.parent;
        CGFloat orgWidth = rb.frame.size.width;
        
        CGFloat fontH = gCharHeightTbl[gSettingMainFontLevel][rb.fontLvl];
        
        if (parent.children.count == 1) {
            CGPoint p = CGPointMake(rb.frame.origin.x, rb.frame.origin.y + rb.frame.size.height - fontH);
            EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :self :TEXTLAYER_EMPTY];
            CGRect temp = l.frame;
            temp.origin.x = p.x;
            temp.origin.y = p.y;
            l.frame = temp;
            l.mainFrame = l.frame;
            l.roll = ROLL_NUMERATOR;
            l.parent = parent;
            l.c_idx = 0;
            [rb destroy];
            [parent.children removeObjectAtIndex:0];
            [parent.children addObject:l];
            [calcB.view.layer addSublayer: l];
            
            [parent updateFrameWidth:l.frame.size.width - orgWidth :l.roll];
            [parent updateFrameHeightS1:l];
            [self.root adjustElementPosition];
            
            cfgEqnBySlctBlk(self, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
        } else {
            if (rb.c_idx == parent.children.count - 1 && [[parent.children objectAtIndex:rb.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                /* Case:  @ @
                          ---
                           *  */
                CGPoint p = CGPointMake(rb.frame.origin.x, rb.frame.origin.y + rb.frame.size.height - fontH);
                EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :self :TEXTLAYER_EMPTY];
                CGRect temp = l.frame;
                temp.origin.x = p.x;
                temp.origin.y = p.y;
                l.frame = temp;
                l.mainFrame = l.frame;
                l.roll = rb.roll;
                l.parent = parent;
                l.c_idx = rb.c_idx;
                [rb destroy];
                [parent.children removeLastObject];
                [parent.children addObject:l];
                [calcB.view.layer addSublayer: l];
                
                [parent updateFrameWidth:l.frame.size.width - orgWidth :l.roll];
                [parent updateFrameHeightS1:l];
                [self.root adjustElementPosition];
                
                cfgEqnBySlctBlk(self, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
            } else if(rb.c_idx == 0 && [[parent.children objectAtIndex:rb.c_idx + 1] isMemberOfClass:[FractionBarLayer class]]) {
                /* Case:  *
                         ---
                         @ @ */
                CGPoint p = CGPointMake(rb.frame.origin.x, rb.frame.origin.y + rb.frame.size.height - fontH);
                EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :self :TEXTLAYER_EMPTY];
                CGRect temp = l.frame;
                temp.origin.x = p.x;
                temp.origin.y = p.y;
                l.frame = temp;
                l.mainFrame = l.frame;
                l.roll = rb.roll;
                l.parent = parent;
                l.c_idx = 0;
                [rb destroy];
                [parent.children removeObjectAtIndex:0];
                [parent.children insertObject:l atIndex:0];
                [calcB.view.layer addSublayer: l];
                
                [parent updateFrameWidth:l.frame.size.width - orgWidth :l.roll];
                [parent updateFrameHeightS1:l];
                [self.root adjustElementPosition];
                
                cfgEqnBySlctBlk(self, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
            } else {
                /* Case:  @ @
                          ---
                          @ @ */
                if (rb.c_idx == 0) {
                    [rb destroy];
                    [parent.children removeObjectAtIndex:0];
                    [parent updateCIdx];
                    
                    [parent updateFrameWidth:-orgWidth :rb.roll];
                    [parent updateFrameHeightS1:[parent.children objectAtIndex:0]];
                    [self.root adjustElementPosition];
                    
                    id b = parent.children.firstObject;
                    if ([b isMemberOfClass:[EquationBlock class]]) {
                        EquationBlock *eb1 = b;
                        calcB.view.cursor.frame = CGRectMake(eb1.mainFrame.origin.x, eb1.mainFrame.origin.y, CURSOR_W, eb1.mainFrame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = eb1.roll;
                    } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        calcB.view.cursor.frame = CGRectMake(l.frame.origin.x, l.frame.origin.y, CURSOR_W, l.frame.size.height);
                        calcB.curTxtLyr = l;
                        calcB.curRoll = l.roll;
                        calcB.txtInsIdx = 0;
                    } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                        RadicalBlock *rb1 = b;
                        calcB.view.cursor.frame = CGRectMake(rb1.frame.origin.x, rb1.frame.origin.y, CURSOR_W, rb1.frame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = rb1.roll;
                    } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                        WrapedEqTxtLyr *wetl = b;
                        calcB.view.cursor.frame = CGRectMake(wetl.mainFrame.origin.x, wetl.mainFrame.origin.y, CURSOR_W, wetl.mainFrame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = wetl.roll;
                    } else if ([b isMemberOfClass:[Parentheses class]]) {
                        Parentheses *p = b;
                        calcB.view.cursor.frame = CGRectMake(p.frame.origin.x, p.frame.origin.y, CURSOR_W, p.frame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = p.roll;
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                        return;
                    }
                    calcB.curMode = MODE_INSERT;
                    calcB.insertCIdx = 0;
                    calcB.curParent = parent;
                    calcB.curBlk = b;
                } else if ([[parent.children objectAtIndex:rb.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                    [rb destroy];
                    [parent.children removeObjectAtIndex:rb.c_idx];
                    [parent updateCIdx];
                    
                    [parent updateFrameWidth:-orgWidth :rb.roll];
                    [parent updateFrameHeightS1:[parent.children objectAtIndex:rb.c_idx]];
                    [self.root adjustElementPosition];
                    
                    id b = [parent.children objectAtIndex:rb.c_idx];
                    if ([b isMemberOfClass:[EquationBlock class]]) {
                        EquationBlock *eb1 = b;
                        calcB.view.cursor.frame = CGRectMake(eb1.mainFrame.origin.x, eb1.mainFrame.origin.y, CURSOR_W, eb1.mainFrame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = eb1.roll;
                    } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        calcB.view.cursor.frame = CGRectMake(l.frame.origin.x, l.frame.origin.y, CURSOR_W, l.frame.size.height);
                        calcB.curTxtLyr = l;
                        calcB.curRoll = l.roll;
                        calcB.txtInsIdx = 0;
                    } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                        RadicalBlock *rb1 = b;
                        calcB.view.cursor.frame = CGRectMake(rb1.frame.origin.x, rb1.frame.origin.y, CURSOR_W, rb1.frame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = rb1.roll;
                    } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                        WrapedEqTxtLyr *wetl = b;
                        calcB.view.cursor.frame = CGRectMake(wetl.mainFrame.origin.x, wetl.mainFrame.origin.y, CURSOR_W, wetl.mainFrame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = wetl.roll;
                    } else if ([b isMemberOfClass:[Parentheses class]]) {
                        Parentheses *p = b;
                        calcB.view.cursor.frame = CGRectMake(p.frame.origin.x, p.frame.origin.y, CURSOR_W, p.frame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = p.roll;
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                        return;
                    }
                    calcB.curMode = MODE_INSERT;
                    calcB.insertCIdx = rb.c_idx;
                    calcB.curParent = parent;
                    calcB.curBlk = b;
                } else {
                    [rb destroy];
                    [parent.children removeObjectAtIndex:rb.c_idx];
                    [parent updateCIdx];
                    
                    id b = [parent.children objectAtIndex:rb.c_idx - 1];
                    [parent updateFrameWidth:-orgWidth :rb.roll];
                    [parent updateFrameHeightS1:b];
                    [self.root adjustElementPosition];
                    
                    if ([b isMemberOfClass:[EquationBlock class]]) {
                        EquationBlock *eb = b;
                        if (eb.bar != nil) {
                            cfgEqnBySlctBlk(self, eb, CGPointMake(eb.bar.frame.origin.x + eb.bar.frame.size.width - 1.0, eb.bar.frame.origin.y + 1.0));
                        } else {
                            cfgEqnBySlctBlk(self, eb, CGPointMake(eb.mainFrame.origin.x + eb.mainFrame.size.width - 1.0, eb.mainFrame.origin.y + eb.mainFrame.size.height - 1.0));
                        }
                    } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        cfgEqnBySlctBlk(self, l, CGPointMake(l.mainFrame.origin.x + l.mainFrame.size.width - 1.0, l.mainFrame.origin.y + 1.0));
                    } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                        RadicalBlock *rb = b;
                        cfgEqnBySlctBlk(self, rb, CGPointMake(rb.frame.origin.x + rb.frame.size.width - 0.5, rb.frame.origin.y + 0.5));
                    } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                        WrapedEqTxtLyr *l = b;
                        cfgEqnBySlctBlk(self, l, CGPointMake(l.mainFrame.origin.x + l.mainFrame.size.width - 1.0, l.mainFrame.origin.y + 1.0));
                    } else if ([b isMemberOfClass:[Parentheses class]]) {
                        Parentheses *p = b;
                        cfgEqnBySlctBlk(self, p, CGPointMake(p.mainFrame.origin.x + p.mainFrame.size.width - 0.5, p.mainFrame.origin.y + 0.5));
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                }
            }
        }
    } else if ([blk isMemberOfClass: [WrapedEqTxtLyr class]]) {
        WrapedEqTxtLyr *wetl = blk;
        if (![wetl.parent isMemberOfClass: [EquationBlock class]]) {
            return;
        }
        EquationBlock *parent = wetl.parent;
        CGFloat orgWidth = wetl.mainFrame.size.width;
        CGFloat fontH = gCharHeightTbl[gSettingMainFontLevel][wetl.fontLvl];
        
        if (parent.children.count == 1) {
            CGPoint p = CGPointMake(wetl.mainFrame.origin.x, wetl.mainFrame.origin.y + wetl.mainFrame.size.height - fontH);
            EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :self :TEXTLAYER_EMPTY];
            CGRect temp = l.frame;
            temp.origin.x = p.x;
            temp.origin.y = p.y;
            l.frame = temp;
            l.mainFrame = l.frame;
            l.roll = ROLL_NUMERATOR;
            l.parent = parent;
            l.c_idx = 0;
            [wetl destroy];
            [parent.children removeObjectAtIndex:0];
            [parent.children addObject:l];
            [calcB.view.layer addSublayer: l];
            
            [parent updateFrameWidth:l.frame.size.width - orgWidth :l.roll];
            [parent updateFrameHeightS1:l];
            [self.root adjustElementPosition];
            
            cfgEqnBySlctBlk(self, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
        } else {
            if (wetl.c_idx == parent.children.count - 1 && [[parent.children objectAtIndex:wetl.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                /* Case:  @ @
                          ---
                           *  */
                CGPoint p = CGPointMake(wetl.mainFrame.origin.x, wetl.mainFrame.origin.y + wetl.mainFrame.size.height - fontH);
                EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :self :TEXTLAYER_EMPTY];
                CGRect temp = l.frame;
                temp.origin.x = p.x;
                temp.origin.y = p.y;
                l.frame = temp;
                l.mainFrame = l.frame;
                l.roll = wetl.roll;
                l.parent = parent;
                l.c_idx = wetl.c_idx;
                [wetl destroy];
                [parent.children removeLastObject];
                [parent.children addObject:l];
                [calcB.view.layer addSublayer: l];
                
                [parent updateFrameWidth:l.frame.size.width - orgWidth :l.roll];
                [parent updateFrameHeightS1:l];
                [self.root adjustElementPosition];
                
                cfgEqnBySlctBlk(self, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
            } else if(wetl.c_idx == 0 && [[parent.children objectAtIndex:wetl.c_idx + 1] isMemberOfClass:[FractionBarLayer class]]) {
                /* Case:  *
                         ---
                         @ @ */
                CGPoint p = CGPointMake(wetl.mainFrame.origin.x, wetl.mainFrame.origin.y + wetl.mainFrame.size.height - fontH);
                EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :self :TEXTLAYER_EMPTY];
                CGRect temp = l.frame;
                temp.origin.x = p.x;
                temp.origin.y = p.y;
                l.frame = temp;
                l.mainFrame = l.frame;
                l.roll = wetl.roll;
                l.parent = parent;
                l.c_idx = 0;
                [wetl destroy];
                [parent.children removeObjectAtIndex:0];
                [parent.children insertObject:l atIndex:0];
                [calcB.view.layer addSublayer: l];
                
                [parent updateFrameWidth:l.frame.size.width - orgWidth :l.roll];
                [parent updateFrameHeightS1:l];
                [self.root adjustElementPosition];
                
                cfgEqnBySlctBlk(self, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
            } else {
                /* Case:  @ @
                          ---
                          @ @ */
                if (wetl.c_idx == 0) {
                    [wetl destroy];
                    [parent.children removeObjectAtIndex:0];
                    [parent updateCIdx];
                    
                    [parent updateFrameWidth:-orgWidth :wetl.roll];
                    [parent updateFrameHeightS1:[parent.children objectAtIndex:0]];
                    [self.root adjustElementPosition];
                    
                    id b = parent.children.firstObject;
                    if ([b isMemberOfClass:[EquationBlock class]]) {
                        EquationBlock *eb1 = b;
                        calcB.view.cursor.frame = CGRectMake(eb1.mainFrame.origin.x, eb1.mainFrame.origin.y, CURSOR_W, eb1.mainFrame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = eb1.roll;
                    } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        calcB.view.cursor.frame = CGRectMake(l.frame.origin.x, l.frame.origin.y, CURSOR_W, l.frame.size.height);
                        calcB.curTxtLyr = l;
                        calcB.curRoll = l.roll;
                        calcB.txtInsIdx = 0;
                    } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                        RadicalBlock *rb1 = b;
                        calcB.view.cursor.frame = CGRectMake(rb1.frame.origin.x, rb1.frame.origin.y, CURSOR_W, rb1.frame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = rb1.roll;
                    } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                        WrapedEqTxtLyr *wetl1 = b;
                        calcB.view.cursor.frame = CGRectMake(wetl1.mainFrame.origin.x, wetl1.mainFrame.origin.y, CURSOR_W, wetl1.mainFrame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = wetl1.roll;
                    } else if ([b isMemberOfClass:[Parentheses class]]) {
                        Parentheses *p = b;
                        calcB.view.cursor.frame = CGRectMake(p.frame.origin.x, p.frame.origin.y, CURSOR_W, p.frame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = p.roll;
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                        return;
                    }
                    calcB.curMode = MODE_INSERT;
                    calcB.insertCIdx = 0;
                    calcB.curParent = parent;
                    calcB.curBlk = b;
                } else if ([[parent.children objectAtIndex:wetl.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                    [wetl destroy];
                    [parent.children removeObjectAtIndex:wetl.c_idx];
                    [parent updateCIdx];
                    
                    [parent updateFrameWidth:-orgWidth :wetl.roll];
                    [parent updateFrameHeightS1:[parent.children objectAtIndex:wetl.c_idx]];
                    [self.root adjustElementPosition];
                    
                    id b = [parent.children objectAtIndex:wetl.c_idx];
                    if ([b isMemberOfClass:[EquationBlock class]]) {
                        EquationBlock *eb1 = b;
                        calcB.view.cursor.frame = CGRectMake(eb1.mainFrame.origin.x, eb1.mainFrame.origin.y, CURSOR_W, eb1.mainFrame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = eb1.roll;
                    } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        calcB.view.cursor.frame = CGRectMake(l.frame.origin.x, l.frame.origin.y, CURSOR_W, l.frame.size.height);
                        calcB.curTxtLyr = l;
                        calcB.curRoll = l.roll;
                        calcB.txtInsIdx = 0;
                    } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                        RadicalBlock *rb1 = b;
                        calcB.view.cursor.frame = CGRectMake(rb1.frame.origin.x, rb1.frame.origin.y, CURSOR_W, rb1.frame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = rb1.roll;
                    } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                        WrapedEqTxtLyr *wetl1 = b;
                        calcB.view.cursor.frame = CGRectMake(wetl1.mainFrame.origin.x, wetl1.mainFrame.origin.y, CURSOR_W, wetl1.mainFrame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = wetl1.roll;
                    } else if ([b isMemberOfClass:[Parentheses class]]) {
                        Parentheses *p = b;
                        calcB.view.cursor.frame = CGRectMake(p.frame.origin.x, p.frame.origin.y, CURSOR_W, p.frame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = p.roll;
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                        return;
                    }
                    calcB.curMode = MODE_INSERT;
                    calcB.insertCIdx = wetl.c_idx;
                    calcB.curParent = parent;
                    calcB.curBlk = b;
                } else {
                    [wetl destroy];
                    [parent.children removeObjectAtIndex:wetl.c_idx];
                    [parent updateCIdx];
                    
                    id b = [parent.children objectAtIndex:wetl.c_idx - 1];
                    [parent updateFrameWidth:-orgWidth :wetl.roll];
                    [parent updateFrameHeightS1:b];
                    [self.root adjustElementPosition];
                    
                    if ([b isMemberOfClass:[EquationBlock class]]) {
                        EquationBlock *eb = b;
                        if (eb.bar != nil) {
                            cfgEqnBySlctBlk(self, eb, CGPointMake(eb.bar.frame.origin.x + eb.bar.frame.size.width - 1.0, eb.bar.frame.origin.y + 1.0));
                        } else {
                            cfgEqnBySlctBlk(self, eb, CGPointMake(eb.mainFrame.origin.x + eb.mainFrame.size.width - 1.0, eb.mainFrame.origin.y + eb.mainFrame.size.height - 1.0));
                        }
                    } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        cfgEqnBySlctBlk(self, l, CGPointMake(l.mainFrame.origin.x + l.mainFrame.size.width - 1.0, l.mainFrame.origin.y + 1.0));
                    } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                        RadicalBlock *rb = b;
                        cfgEqnBySlctBlk(self, rb, CGPointMake(rb.frame.origin.x + rb.frame.size.width - 0.5, rb.frame.origin.y + 0.5));
                    } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                        WrapedEqTxtLyr *wetl1 = b;
                        cfgEqnBySlctBlk(self, wetl1, CGPointMake(wetl1.mainFrame.origin.x + wetl1.mainFrame.size.width - 1.0, wetl1.mainFrame.origin.y + 1.0));
                    } else if ([b isMemberOfClass:[Parentheses class]]) {
                        Parentheses *p = b;
                        cfgEqnBySlctBlk(self, p, CGPointMake(p.mainFrame.origin.x + p.mainFrame.size.width - 0.5, p.mainFrame.origin.y + 0.5));
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                }
            }
        }
    } else if ([blk isMemberOfClass: [Parentheses class]]) {
        Parentheses *parenth = blk;
        if (![parenth.parent isMemberOfClass: [EquationBlock class]]) {
            return;
        }
        EquationBlock *parent = parenth.parent;
        CGFloat orgWidth = parenth.mainFrame.size.width;
        
        CGFloat fontH = gCharHeightTbl[gSettingMainFontLevel][parent.fontLvl];
        
        if (parent.children.count == 1) {
            CGPoint p = CGPointMake(parenth.frame.origin.x, parenth.frame.origin.y + parenth.frame.size.height - fontH);
            EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :self :TEXTLAYER_EMPTY];
            CGRect temp = l.frame;
            temp.origin.x = p.x;
            temp.origin.y = p.y;
            l.frame = temp;
            l.mainFrame = l.frame;
            l.roll = ROLL_NUMERATOR;
            l.parent = parent;
            l.c_idx = 0;
            [parenth destroy];
            [parent.children removeObjectAtIndex:0];
            [parent.children addObject:l];
            [calcB.view.layer addSublayer: l];
            
            [parent updateFrameWidth:l.frame.size.width - orgWidth :l.roll];
            [parent updateFrameHeightS1:l];
            [self.root adjustElementPosition];
            
            cfgEqnBySlctBlk(self, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
        } else {
            if (parenth.c_idx == parent.children.count - 1 && [[parent.children objectAtIndex:parenth.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                /* Case:  @ @
                          ---
                           *  */
                CGPoint p = CGPointMake(parenth.frame.origin.x, parenth.frame.origin.y + parenth.frame.size.height - fontH);
                EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :self :TEXTLAYER_EMPTY];
                CGRect temp = l.frame;
                temp.origin.x = p.x;
                temp.origin.y = p.y;
                l.frame = temp;
                l.mainFrame = l.frame;
                l.roll = parenth.roll;
                l.parent = parent;
                l.c_idx = parenth.c_idx;
                [parenth destroy];
                [parent.children removeLastObject];
                [parent.children addObject:l];
                [calcB.view.layer addSublayer: l];
                
                [parent updateFrameWidth:l.frame.size.width - orgWidth :l.roll];
                [parent updateFrameHeightS1:l];
                [self.root adjustElementPosition];
                
                cfgEqnBySlctBlk(self, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
            } else if(parenth.c_idx == 0 && [[parent.children objectAtIndex:parenth.c_idx + 1] isMemberOfClass:[FractionBarLayer class]]) {
                /* Case:  *
                         ---
                         @ @ */
                CGPoint p = CGPointMake(parenth.frame.origin.x, parenth.frame.origin.y + parenth.frame.size.height - fontH);
                EquationTextLayer *l = [[EquationTextLayer alloc] init:@"_" :self :TEXTLAYER_EMPTY];
                CGRect temp = l.frame;
                temp.origin.x = p.x;
                temp.origin.y = p.y;
                l.frame = temp;
                l.mainFrame = l.frame;
                l.roll = parenth.roll;
                l.parent = parent;
                l.c_idx = 0;
                [parenth destroy];
                [parent.children removeObjectAtIndex:0];
                [parent.children insertObject:l atIndex:0];
                [calcB.view.layer addSublayer: l];
                
                [parent updateFrameWidth:l.frame.size.width - orgWidth :l.roll];
                [parent updateFrameHeightS1:l];
                [self.root adjustElementPosition];
                
                cfgEqnBySlctBlk(self, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
            } else {
                /* Case:  @ @
                          ---
                          @ @ */
                if (parenth.c_idx == 0) {
                    [parenth destroy];
                    [parent.children removeObjectAtIndex:0];
                    [parent updateCIdx];
                    
                    [parent updateFrameWidth:-orgWidth :parenth.roll];
                    [parent updateFrameHeightS1:[parent.children objectAtIndex:0]];
                    [self.root adjustElementPosition];
                    
                    id b = parent.children.firstObject;
                    if ([b isMemberOfClass:[EquationBlock class]]) {
                        EquationBlock *eb1 = b;
                        calcB.view.cursor.frame = CGRectMake(eb1.mainFrame.origin.x, eb1.mainFrame.origin.y, CURSOR_W, eb1.mainFrame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = eb1.roll;
                    } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        calcB.view.cursor.frame = CGRectMake(l.frame.origin.x, l.frame.origin.y, CURSOR_W, l.frame.size.height);
                        calcB.curTxtLyr = l;
                        calcB.curRoll = l.roll;
                        calcB.txtInsIdx = 0;
                    } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                        RadicalBlock *rb1 = b;
                        calcB.view.cursor.frame = CGRectMake(rb1.frame.origin.x, rb1.frame.origin.y, CURSOR_W, rb1.frame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = rb1.roll;
                    } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                        WrapedEqTxtLyr *wetl1 = b;
                        calcB.view.cursor.frame = CGRectMake(wetl1.mainFrame.origin.x, wetl1.mainFrame.origin.y, CURSOR_W, wetl1.mainFrame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = wetl1.roll;
                    } else if ([b isMemberOfClass:[Parentheses class]]) {
                        Parentheses *p = b;
                        calcB.view.cursor.frame = CGRectMake(p.frame.origin.x, p.frame.origin.y, CURSOR_W, p.frame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = p.roll;
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                        return;
                    }
                    calcB.curMode = MODE_INSERT;
                    calcB.insertCIdx = 0;
                    calcB.curParent = parent;
                    calcB.curBlk = b;
                } else if ([[parent.children objectAtIndex:parenth.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                    [parenth destroy];
                    [parent.children removeObjectAtIndex:parenth.c_idx];
                    [parent updateCIdx];
                    
                    [parent updateFrameWidth:-orgWidth :parenth.roll];
                    [parent updateFrameHeightS1:[parent.children objectAtIndex:parenth.c_idx]];
                    [self.root adjustElementPosition];
                    
                    id b = [parent.children objectAtIndex:parenth.c_idx];
                    if ([b isMemberOfClass:[EquationBlock class]]) {
                        EquationBlock *eb1 = b;
                        calcB.view.cursor.frame = CGRectMake(eb1.mainFrame.origin.x, eb1.mainFrame.origin.y, CURSOR_W, eb1.mainFrame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = eb1.roll;
                    } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        calcB.view.cursor.frame = CGRectMake(l.frame.origin.x, l.frame.origin.y, CURSOR_W, l.frame.size.height);
                        calcB.curTxtLyr = l;
                        calcB.curRoll = l.roll;
                        calcB.txtInsIdx = 0;
                    } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                        RadicalBlock *rb1 = b;
                        calcB.view.cursor.frame = CGRectMake(rb1.frame.origin.x, rb1.frame.origin.y, CURSOR_W, rb1.frame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = rb1.roll;
                    } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                        WrapedEqTxtLyr *wetl1 = b;
                        calcB.view.cursor.frame = CGRectMake(wetl1.mainFrame.origin.x, wetl1.mainFrame.origin.y, CURSOR_W, wetl1.mainFrame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = wetl1.roll;
                    } else if ([b isMemberOfClass:[Parentheses class]]) {
                        Parentheses *p = b;
                        calcB.view.cursor.frame = CGRectMake(p.frame.origin.x, p.frame.origin.y, CURSOR_W, p.frame.size.height);
                        calcB.curTxtLyr = nil;
                        calcB.curRoll = p.roll;
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                        return;
                    }
                    calcB.curMode = MODE_INSERT;
                    calcB.insertCIdx = parenth.c_idx;
                    calcB.curParent = parent;
                    calcB.curBlk = b;
                } else {
                    [parenth destroy];
                    [parent.children removeObjectAtIndex:parenth.c_idx];
                    [parent updateCIdx];
                    
                    id b = [parent.children objectAtIndex:parenth.c_idx - 1];
                    [parent updateFrameWidth:-orgWidth :parenth.roll];
                    [parent updateFrameHeightS1:b];
                    [self.root adjustElementPosition];
                    
                    if ([b isMemberOfClass:[EquationBlock class]]) {
                        EquationBlock *eb = b;
                        if (eb.bar != nil) {
                            cfgEqnBySlctBlk(self, eb, CGPointMake(eb.bar.frame.origin.x + eb.bar.frame.size.width - 1.0, eb.bar.frame.origin.y + 1.0));
                        } else {
                            cfgEqnBySlctBlk(self, eb, CGPointMake(eb.mainFrame.origin.x + eb.mainFrame.size.width - 1.0, eb.mainFrame.origin.y + eb.mainFrame.size.height - 1.0));
                        }
                    } else if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        cfgEqnBySlctBlk(self, l, CGPointMake(l.mainFrame.origin.x + l.mainFrame.size.width - 1.0, l.mainFrame.origin.y + 1.0));
                    } else if ([b isMemberOfClass:[RadicalBlock class]]) {
                        RadicalBlock *rb = b;
                        cfgEqnBySlctBlk(self, rb, CGPointMake(rb.frame.origin.x + rb.frame.size.width - 1.0, rb.frame.origin.y + 1.0));
                    } else if ([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                        WrapedEqTxtLyr *l = b;
                        cfgEqnBySlctBlk(self, l, CGPointMake(l.mainFrame.origin.x + l.mainFrame.size.width - 1.0, l.mainFrame.origin.y + 1.0));
                    } else if ([b isMemberOfClass:[Parentheses class]]) {
                        Parentheses *p = b;
                        cfgEqnBySlctBlk(self, p, CGPointMake(p.mainFrame.origin.x + p.mainFrame.size.width - 0.5, p.mainFrame.origin.y + 0.5));
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                }
            }
        }
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
}

-(void) moveUpDown : (CGFloat)distance {
    [self.root moveUpDown:distance];
    if (self.result != nil) {
        self.result.frame = CGRectOffset(self.result.frame, 0.0, distance);
        self.result.mainFrame = self.result.frame;
        self.equalsign.frame = CGRectOffset(self.equalsign.frame, 0.0, distance);
        self.equalsign.mainFrame = self.equalsign.frame;
        self.timeRec.frame = CGRectOffset(self.timeRec.frame, 0.0, distance);
        self.separator.frame = CGRectOffset(self.separator.frame, 0.0, distance);
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
}

-(void) destroyWithAnim {
    [self.root destroyWithAnim];
    self.root = nil;
    if (self.result != nil) {
        [self.equalsign destroyWithAnim];
        self.equalsign = nil;
        [self.result destroyWithAnim];
        self.result = nil;
        [self.timeRec removeFromSuperview];
        self.timeRec = nil;
        [self.separator removeFromSuperlayer];
        self.separator = nil;
    }
}

-(void) formatResult:(NSNumber *)res {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.maximumFractionDigits = gSettingMaxFractionDigits;
    if ([res compare:gSettingMaxDecimal] == NSOrderedDescending) {
        formatter.numberStyle = NSNumberFormatterScientificStyle;
    } else {
        if (gSettingThousandSeperator) {
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
        } else {
            formatter.numberStyle = NSNumberFormatterNoStyle;
        }
    }
    
    self.result = [[EquationTextLayer alloc] init:[formatter stringFromNumber:res] :gCurCB.curEq :TEXTLAYER_NUM];
    return;
}

-(void) destroy {
    [self.root destroy];
    self.root = nil;
    if (self.result != nil) {
        [self.equalsign destroy];
        self.equalsign = nil;
        [self.result destroy];
        self.result = nil;
        [self.timeRec removeFromSuperview];
        self.timeRec = nil;
        [self.separator removeFromSuperlayer];
        self.separator = nil;
    }
}
@end
