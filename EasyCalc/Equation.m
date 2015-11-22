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

@class EquationTextLayer;
@class EquationBlock;

@implementation Equation
@synthesize guid_cnt;
@synthesize root;
@synthesize curPoint;
@synthesize curParent;
@synthesize curBlock;
@synthesize curTextLayer;
@synthesize curRoll;
@synthesize curMode;
@synthesize baseFont;
@synthesize superscriptFont;
@synthesize curFont;
@synthesize baseCharWidth;
@synthesize baseCharHight;
@synthesize expoCharWidth;
@synthesize expoCharHight;
@synthesize curFontH;
@synthesize curFontW;
@synthesize insertCIdx;
@synthesize needX;
@synthesize view;
@synthesize needNewLayer;

-(id) init {
    self = [super init];
    if (self) {
        guid_cnt = 0;
        curRoll = ROLL_NUMERATOR;
        curMode = MODE_INPUT;
        needX = NO;
        needNewLayer = YES;
        
        baseFont = [UIFont systemFontOfSize: 20];
        superscriptFont = [UIFont systemFontOfSize:8];
        curFont = baseFont;
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: @"8"];
        CTFontRef ctFont = CTFontCreateWithName((CFStringRef)baseFont.fontName, baseFont.pointSize, NULL);
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        CGSize strSize = [attStr size];
        baseCharWidth = strSize.width;
        baseCharHight = strSize.height;
        attStr = [[NSMutableAttributedString alloc] initWithString: @"8"];
        ctFont = CTFontCreateWithName((CFStringRef)superscriptFont.fontName, superscriptFont.pointSize, NULL);
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        strSize = [attStr size];
        expoCharWidth = strSize.width;
        expoCharHight = strSize.height;
        
        curFontW = baseCharWidth;
        curFontH = baseCharHight;
        
        root = [[EquationBlock alloc] init:self];
        root.numerTopHalf = baseCharHight / 2.0;
        root.numerBtmHalf = baseCharHight / 2.0;
        root.roll = ROLL_ROOT;
        root.parent = nil;
        curParent = root;
        
        NSLog(@"%s%i---%.1f-%.1f-%.1f-%.1f-", __FUNCTION__, __LINE__, baseCharWidth, baseCharHight, expoCharWidth, expoCharHight);
        
        [self addObserver:self forKeyPath:@"curFont" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

-(id) init : (CGPoint)rootPos : (CGRect)dspFrame : (CGRect)cursorFrame : (ViewController *)vc {
    self = [super init];
    if (self) {
        guid_cnt = 0;
        curRoll = ROLL_NUMERATOR;
        curMode = MODE_INPUT;
        needX = NO;
        
        baseFont = [UIFont systemFontOfSize: 20];
        superscriptFont = [UIFont systemFontOfSize:10];
        curFont = baseFont;
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: @"8"];
        CTFontRef ctFont = CTFontCreateWithName((CFStringRef)baseFont.fontName, baseFont.pointSize, NULL);
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        CGSize strSize = [attStr size];
        baseCharWidth = strSize.width;
        baseCharHight = strSize.height;
        attStr = [[NSMutableAttributedString alloc] initWithString: @"8"];
        ctFont = CTFontCreateWithName((CFStringRef)superscriptFont.fontName, superscriptFont.pointSize, NULL);
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        strSize = [attStr size];
        expoCharWidth = strSize.width;
        expoCharHight = strSize.height;
        
        curFontW = baseCharWidth;
        curFontH = baseCharHight;
        
        DisplayView *dspView = [[DisplayView alloc] initWithFrame:dspFrame];
        dspView.backgroundColor = [UIColor lightGrayColor];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:vc action:@selector(handleTap:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [dspView addGestureRecognizer:tapGesture];
        
        UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:vc action:@selector(handleSwipeRight:)];
        right.numberOfTouchesRequired = 1;
        right.direction = UISwipeGestureRecognizerDirectionRight;
        [dspView addGestureRecognizer:right];
        
        UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:vc action:@selector(handleSwipeLeft:)];
        left.numberOfTouchesRequired = 1;
        left.direction = UISwipeGestureRecognizerDirectionLeft;
        [dspView addGestureRecognizer:left];

        CALayer *clayer = [CALayer layer];
        clayer.contentsScale = [UIScreen mainScreen].scale;
        clayer.name = @"cursorLayer";
        clayer.hidden = NO;
        clayer.backgroundColor = [UIColor clearColor].CGColor;
        CGRect tmpF = cursorFrame;
        tmpF.size = CGSizeMake(3.0, baseCharHight);
        clayer.frame = tmpF;
        clayer.delegate = vc;
        [dspView.layer addSublayer:clayer];
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"hidden"];
        anim.fromValue = [NSNumber numberWithBool:YES];
        anim.toValue = [NSNumber numberWithBool:NO];
        anim.duration = 0.5;
        anim.autoreverses = YES;
        anim.repeatCount = HUGE_VALF;
        [clayer addAnimation:anim forKey:nil];
        [clayer setNeedsDisplay];

        root = [[EquationBlock alloc] init:rootPos :self];
        root.roll = ROLL_ROOT;
        root.parent = nil;
        curParent = root;

        EquationTextLayer *layer = [[EquationTextLayer alloc] init:@"_" :rootPos :self :TEXTLAYER_EMPTY];
        layer.parent = root;
        root.numerFrame = layer.frame;
        root.mainFrame = layer.frame;
        NSLog(@"[%s%i]~%.1f~~~~~~~~~~", __FUNCTION__, __LINE__, layer.frame.size.width);
        layer.c_idx = 0;
        [root.children addObject:layer];
        [dspView.layer addSublayer:layer];
        curTextLayer = layer;
        curBlock = layer;

        dspView.cursor = clayer;
        dspView.inpOrg = clayer.frame.origin;
        view = dspView;

        NSLog(@"%s%i---%.1f-%.1f-%.1f-%.1f-", __FUNCTION__, __LINE__, baseCharWidth, baseCharHight, expoCharWidth, expoCharHight);
        
        [self addObserver:self forKeyPath:@"curFont" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

-(void) dumpObj : (EquationBlock *)parentBlock {
    NSLog(@"%s~eBlk~id:%i~Cidx:%lu~roll:%i>[%.1f %.1f %.1f %.1f]>[%.1f %.1f %.1f %.1f]>[%.1f %.1f %.1f %.1f]>>>>", __FUNCTION__, parentBlock.guid, (unsigned long)parentBlock.c_idx, parentBlock.roll, parentBlock.mainFrame.origin.x, parentBlock.mainFrame.origin.y, parentBlock.mainFrame.size.width, parentBlock.mainFrame.size.height, parentBlock.numerFrame.origin.x, parentBlock.numerFrame.origin.y, parentBlock.numerFrame.size.width, parentBlock.numerFrame.size.height, parentBlock.denomFrame.origin.x, parentBlock.denomFrame.origin.y, parentBlock.denomFrame.size.width, parentBlock.denomFrame.size.height);
    NSMutableArray *blockChildren = parentBlock.children;
    NSEnumerator *enumerator = [blockChildren objectEnumerator];
    id cb;
    while (cb = [enumerator nextObject]) {
        if ([cb isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *layer = cb;
            if (layer.expo != nil) {
                NSLog(@"%s~Txt~id:%i~Cidx:%lu~roll:%i~with expo>>>>", __FUNCTION__, layer.guid, (unsigned long)layer.c_idx, layer.roll);
                [self dumpObj:layer.expo];
                NSLog(@"%s~Txt~id:%i~<<<<<<<<<", __FUNCTION__, layer.guid);
            } else {
                NSLog(@"%s~Txt~id:%i~Cidx:%lu~roll:%i~~~~~~~~~", __FUNCTION__, layer.guid, (unsigned long)layer.c_idx, layer.roll);
            }
        }
        
        if ([cb isMemberOfClass: [FractionBarLayer class]]) {
            FractionBarLayer *bar = cb;
            NSLog(@"%s~Bar~id:%i~Cidx:%lu~~~~~~~~~", __FUNCTION__, bar.guid, (unsigned long)bar.c_idx);
        }
        
        if ([cb isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *block = cb;
            [self dumpObj:block];
        }
        
        if ([cb isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *block = cb;
            NSLog(@"%s~rBlk~id:%i~Cidx:%lu~roll:%i>[%.1f %.1f %.1f %.1f]>>>>>", __FUNCTION__, block.guid, (unsigned long)block.c_idx, block.roll, block.frame.origin.x, block.frame.origin.y, block.frame.size.width, block.frame.size.height);
            [self dumpObj:block.content];
            NSLog(@"%s~rBlk~%i<<<<<<", __FUNCTION__, block.guid);
        }
    }
    NSLog(@"%s~eBlk~%i<<<<<<", __FUNCTION__, parentBlock.guid);
}

-(void) dumpEverything : (EquationBlock *)eb {
    [self dumpObj:eb];
}

-(id) lookForElementByPoint : (EquationBlock *)rootB : (CGPoint) point {
    CGFloat x = rootB.mainFrame.origin.x;
    CGFloat y = rootB.mainFrame.origin.y;
    CGFloat w = rootB.mainFrame.size.width;
    CGFloat h = rootB.mainFrame.size.height;
    
    if (!(point.y >= y && point.y <= y + h && point.x >= x && point.x <= x + w)) {
        return nil;
    }
    
    for (id child in rootB.children) {
        if ([child isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *eB = child;
            CGFloat x = eB.mainFrame.origin.x;
            CGFloat y = eB.mainFrame.origin.y;
            CGFloat w = eB.mainFrame.size.width;
            CGFloat h = eB.mainFrame.size.height;
            if (point.y >= y && point.y <= y + h && point.x >= x && point.x <= x + w) {
                return [self lookForElementByPoint :eB :point];
            }
        } else if ([child isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *layer = child;
            EquationBlock *expo = layer.expo;
            CGFloat x = layer.mainFrame.origin.x;
            CGFloat y = layer.mainFrame.origin.y;
            CGFloat w = layer.mainFrame.size.width;
            CGFloat h = layer.mainFrame.size.height;
            
            if (layer.expo != nil) {
                CGFloat ex = expo.mainFrame.origin.x;
                CGFloat ey = expo.mainFrame.origin.y;
                CGFloat ew = expo.mainFrame.size.width;
                CGFloat eh = expo.mainFrame.size.height;
                
                if (point.y >= y && point.y <= y + h && point.x >= x && point.x <= x + w) { // In the main frame
                    if (point.y >= ey && point.y <= ey + eh && point.x >= ex && point.x <= ex + ew) { // In expo
                        return [self lookForElementByPoint :expo :point];
                    } else { // In base or blank
                        return layer;
                    }
                }
                
            } else {
                if (point.y >= y && point.y <= y + h && point.x >= x && point.x <= x + w) { // In the main frame
                    return layer;
                }
            }
        } else if ([child isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *rB = child;
            CGFloat x = rB.frame.origin.x;
            CGFloat y = rB.frame.origin.y;
            CGFloat w = rB.frame.size.width;
            CGFloat h = rB.frame.size.height;
            if (point.y >= y && point.y <= y + h && point.x >= x && point.x <= x + w) {
                EquationBlock *eb = rB.content;
                CGFloat ex = eb.mainFrame.origin.x;
                CGFloat ey = eb.mainFrame.origin.y;
                CGFloat ew = eb.mainFrame.size.width;
                CGFloat eh = eb.mainFrame.size.height;
                
                if (point.y >= ey && point.y <= ey + eh && point.x >= ex && point.x <= ex + ew) {
                    return [self lookForElementByPoint :eb :point];
                } else {
                    return rB;
                }
            }
        } else if ([child isMemberOfClass: [FractionBarLayer class]]) {
            FractionBarLayer *bar = child;
            CGFloat x = bar.frame.origin.x;
            CGFloat y = bar.frame.origin.y;
            CGFloat w = bar.frame.size.width;
            CGFloat h = bar.frame.size.height;
            
            if (point.y >= y && point.y <= y + h && point.x >= x && point.x <= x + w) {
                return bar;
            }
        } else
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    
    return rootB;
}



-(void) adjustEveryThing : (EquationBlock *)parentBlock {
    /* First adjust numerFrame and denomFrame */
    CGFloat mainCenterX = parentBlock.mainFrame.origin.x + (parentBlock.mainFrame.size.width / 2.0);
    
    CGFloat curNumX = 0.0; // Track the layer/block orgin x
    CGFloat curDenX = 0.0; // Track the layer/block orgin x
    CGRect frame = parentBlock.numerFrame;
    frame.origin.y = parentBlock.mainFrame.origin.y;
    frame.origin.x = mainCenterX - (frame.size.width / 2.0);
    parentBlock.numerFrame = frame;
    curNumX = frame.origin.x;
    
    if (parentBlock.bar != nil) {
        frame = parentBlock.denomFrame;
        frame.origin.y = parentBlock.mainFrame.origin.y + parentBlock.numerFrame.size.height;
        frame.origin.x = mainCenterX - (frame.size.width / 2.0);
        parentBlock.denomFrame = frame;
        curDenX = frame.origin.x;
    }
    
    /* Then adjust blocks */
    NSMutableArray *blockChildren = parentBlock.children;
    NSEnumerator *enumerator = [blockChildren objectEnumerator];
    id cb;
    while (cb = [enumerator nextObject]) {
        if ([cb isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *layer = cb;
            
            if (layer.roll == ROLL_NUMERATOR) {
                CGRect frame = layer.frame;
                frame.origin.y = parentBlock.numerFrame.origin.y + parentBlock.numerTopHalf - (layer.frame.size.height / 2.0);
                frame.origin.x = curNumX;
                layer.frame = frame;
                [layer updateFrameBaseOnBase];
                curNumX += layer.mainFrame.size.width;
            } else if (layer.roll == ROLL_DENOMINATOR) {
                CGRect frame = layer.frame;
                frame.origin.y = parentBlock.denomFrame.origin.y + parentBlock.denomTopHalf - (layer.frame.size.height / 2.0);
                frame.origin.x = curDenX;
                layer.frame = frame;
                [layer updateFrameBaseOnBase];
                curDenX += layer.mainFrame.size.width;
            } else
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            
            if (layer.expo != nil) {
                EquationBlock *b = layer.expo;
                [self adjustEveryThing:b];
            }
        } else if ([cb isMemberOfClass: [FractionBarLayer class]]) {
            FractionBarLayer *bar = cb;
            CGRect frame = bar.frame;
            frame.origin.x = parentBlock.mainFrame.origin.x;
            frame.origin.y = parentBlock.mainFrame.origin.y + parentBlock.numerFrame.size.height - (frame.size.height / 2.0);
            if ((int)frame.size.width != (int)parentBlock.mainFrame.size.width) {
                frame.size.width = parentBlock.mainFrame.size.width;
                bar.frame = frame;
                [bar setNeedsDisplay];
            } else {
                bar.frame = frame;
            }
        } else if ([cb isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *block = cb;
            
            if (block.roll == ROLL_NUMERATOR) {
                CGRect frame = block.mainFrame;
                frame.origin.y = parentBlock.numerFrame.origin.y + parentBlock.numerTopHalf - (block.mainFrame.size.height / 2.0);
                frame.origin.x = curNumX;
                block.mainFrame = frame;
                curNumX += frame.size.width;
            } else if (block.roll == ROLL_DENOMINATOR) {
                CGRect frame = block.mainFrame;
                frame.origin.y = parentBlock.denomFrame.origin.y + parentBlock.denomTopHalf - (block.mainFrame.size.height / 2.0);
                frame.origin.x = curDenX;
                block.mainFrame = frame;
                curDenX += frame.size.width;
            } else
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            
            [self adjustEveryThing:block];
        } else if ([cb isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *block = cb;
            CGRect mainF = block.content.mainFrame;
            CGRect frame = block.frame;
            
            if (block.roll == ROLL_NUMERATOR || block.roll == ROLL_ROOT_ROOT) {
                frame.origin.y = parentBlock.numerFrame.origin.y + parentBlock.numerTopHalf - (block.frame.size.height / 2.0);
                frame.origin.x = curNumX;
                block.frame = frame;
                curNumX += frame.size.width;
            } else if (block.roll == ROLL_DENOMINATOR) {
                frame.origin.y = parentBlock.denomFrame.origin.y + parentBlock.denomTopHalf - (block.frame.size.height / 2.0);
                frame.origin.x = curDenX;
                block.frame = frame;
                curDenX += frame.size.width;
            } else
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            if (block.rootNum != nil) {
                CGFloat ML = RADICAL_MARGINE_L_PERC * block.frame.size.height;
                CGRect f = block.rootNum.frame;
                block.rootNum.frame = CGRectMake(frame.origin.x + ML / 2.0 - 4.0, frame.origin.y, f.size.width, f.size.height);
            }
            
            frame.origin.x += RADICAL_MARGINE_L_PERC * block.frame.size.height;
            frame.origin.y += RADICAL_MARGINE_T;
            mainF.origin = frame.origin;
            block.content.mainFrame = mainF;
            
            [self adjustEveryThing:block.content];
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqual: @"curFont"]) {
        Equation *e = object;
        UIFont *newFont = [change objectForKey:@"new"];
        if (newFont == e.baseFont) {
            e.curFontW = e.baseCharWidth;
            e.curFontH = e.baseCharHight;
        } else if (newFont == e.superscriptFont) {
            e.curFontW = e.expoCharWidth;
            e.curFontH = e.expoCharHight;
        } else
            NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        
        NSLog(@"[%s%i]~~~~~~~~~~~", __FUNCTION__, __LINE__);
    }
}
@end
