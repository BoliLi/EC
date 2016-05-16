//
//  Global.m
//  EasyCalc
//
//  Created by LiBoli on 15/11/20.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"
#import "Equation.h"
#import "EquationBlock.h"
#import "EquationTextLayer.h"
#import "RadicalBlock.h"
#import "FractionBarLayer.h"
#import "WrapedEqTxtLyr.h"
#import "Parentheses.h"
#import "CalcBoard.h"


NSMutableArray *gCalcBoardList;
NSInteger gCurCBIdx = 0;
CalcBoard *gCurCB;
CGFloat gCharWidthTbl[4][17];
CGFloat gCharHeightTbl[4];
NSMutableArray *gTemplateList;

@implementation NSMutableArray (EasyCalc)
- (void)reverse {
    if ([self count] <= 1)
        return;
    NSUInteger i = 0;
    NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:j];

        i++;
        j--;
    }
}
@end

@implementation UIButton (EasyCalc)
- (UIImage *) buttonImageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
@end

UIFont *getFont(int lvl) {
    return [UIFont fontWithName:@"AvenirNextCondensed-UltraLight" size:getFontSize(lvl)];
}

int getFontSize(int level) {
    if (level == 0) {
        return 30;
    } else if (level == 1) {
        return 15;
    } else if (level == 2) {
        return 7;
    } else {
        return 4;
    }
}

CGFloat getLineWidth(int level) {
    if (level == 0) {
        return 2.0;
    } else if (level == 1) {
        return 1.0;
    } else if (level == 2) {
        return 0.5;
    } else {
        return 0.5;
    }
}

void initCharSizeTbl(void) {
    for (int j = 0; j < 4; j++) {
        int i;
        UIFont *font = getFont(j);
        
        gCharHeightTbl[j] = font.lineHeight;
        
        CTFontRef ctFont = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
        for (i = 0; i < 10; i++) {
            NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%d",i]];
            [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
            gCharWidthTbl[j][i] = [attStr size].width;
        }
        
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:@"."];
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        gCharWidthTbl[j][i++] = [attStr size].width;
        
        attStr = [[NSMutableAttributedString alloc] initWithString:@"+"];
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        gCharWidthTbl[j][i++] = [attStr size].width;
        
        attStr = [[NSMutableAttributedString alloc] initWithString:@"-"];
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        gCharWidthTbl[j][i++] = [attStr size].width;
        
        attStr = [[NSMutableAttributedString alloc] initWithString:@"×"];
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        gCharWidthTbl[j][i++] = [attStr size].width;
        
        attStr = [[NSMutableAttributedString alloc] initWithString:@"("];
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        gCharWidthTbl[j][i++] = [attStr size].width;
        
        attStr = [[NSMutableAttributedString alloc] initWithString:@")"];
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        gCharWidthTbl[j][i++] = [attStr size].width;
        
        attStr = [[NSMutableAttributedString alloc] initWithString:@"_"];
        [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, 1)];
        gCharWidthTbl[j][i++] = [attStr size].width;
        
        CFRelease(ctFont);
    }
    
    NSMutableString *str = [NSMutableString string];
    for (int i = 0; i < 16; i++) {
        [str appendString:[NSString stringWithFormat:@"%f ", gCharWidthTbl[0][i]]];
    }
    NSLog(@"%s%i>~%@~~~~~~~~~~", __FUNCTION__, __LINE__, str);
}

CGFloat getCharWidth(int level, NSString *s) {
    if ([s isEqual:@"0"]) {
        return gCharWidthTbl[level][0];
    } else if ([s isEqual:@"1"]) {
        return gCharWidthTbl[level][1];
    } else if ([s isEqual:@"2"]) {
        return gCharWidthTbl[level][2];
    } else if ([s isEqual:@"3"]) {
        return gCharWidthTbl[level][3];
    } else if ([s isEqual:@"4"]) {
        return gCharWidthTbl[level][4];
    } else if ([s isEqual:@"5"]) {
        return gCharWidthTbl[level][5];
    } else if ([s isEqual:@"6"]) {
        return gCharWidthTbl[level][6];
    } else if ([s isEqual:@"7"]) {
        return gCharWidthTbl[level][7];
    } else if ([s isEqual:@"8"]) {
        return gCharWidthTbl[level][8];
    } else if ([s isEqual:@"9"]) {
        return gCharWidthTbl[level][9];
    } else if ([s isEqual:@"."]) {
        return gCharWidthTbl[level][10];
    } else if ([s isEqual:@"+"]) {
        return gCharWidthTbl[level][11];
    } else if ([s isEqual:@"-"]) {
        return gCharWidthTbl[level][12];
    } else if ([s isEqual:@"×"]) {
        return gCharWidthTbl[level][13];
    } else if ([s isEqual:@"("]) {
        return gCharWidthTbl[level][14];
    } else if ([s isEqual:@")"]) {
        return gCharWidthTbl[level][15];
    } else if ([s isEqual:@"_"]) {
        return gCharWidthTbl[level][16];
    } else {
        NSLog(@"%s%i>~%@~ERR~~~~~~~~~", __FUNCTION__, __LINE__, s);
        return 0.0;
    }
}

void drawFrame(ViewController *vc, UIView *view, EquationBlock *parentBlock) {
    
    CALayer *layer = [CALayer layer];
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.name = @"drawframe";
    layer.backgroundColor = [UIColor clearColor].CGColor;
    layer.frame = parentBlock.mainFrame;
    layer.delegate = vc;
    [view.layer addSublayer: layer];
    [layer setNeedsDisplay];

    CALayer *layer1 = [CALayer layer];
    layer1.contentsScale = [UIScreen mainScreen].scale;
    layer1.name = @"drawframe";
    layer1.backgroundColor = [UIColor clearColor].CGColor;
    layer1.frame = parentBlock.numerFrame;
    layer1.delegate = vc;
    [view.layer addSublayer: layer1];
    [layer1 setNeedsDisplay];

    CALayer *layer2 = [CALayer layer];
    layer2.contentsScale = [UIScreen mainScreen].scale;
    layer2.name = @"drawframe";
    layer2.backgroundColor = [UIColor clearColor].CGColor;
    layer2.frame = parentBlock.denomFrame;
    layer2.delegate = vc;
    [view.layer addSublayer: layer2];
    [layer2 setNeedsDisplay];
    
    NSMutableArray *blockChildren = parentBlock.children;
    NSEnumerator *enumerator = [blockChildren objectEnumerator];
    id cb;
    while (cb = [enumerator nextObject]) {
        if ([cb isMemberOfClass: [EquationTextLayer class]]) {
            EquationTextLayer *tLayer = cb;
            CALayer *layer = [CALayer layer];
            layer.contentsScale = [UIScreen mainScreen].scale;
            layer.name = @"drawframe";
            layer.backgroundColor = [UIColor clearColor].CGColor;
            layer.frame = tLayer.mainFrame;
            layer.delegate = vc;
            [view.layer addSublayer: layer];
            [layer setNeedsDisplay];
            
            CALayer *layer1 = [CALayer layer];
            layer1.contentsScale = [UIScreen mainScreen].scale;
            layer1.name = @"drawframe";
            layer1.backgroundColor = [UIColor clearColor].CGColor;
            layer1.frame = tLayer.frame;
            layer1.delegate = vc;
            [view.layer addSublayer: layer1];
            [layer1 setNeedsDisplay];
            
            if (tLayer.expo != nil) {
                
                drawFrame(vc, view, tLayer.expo);
            } else {
            }
        }
        
        if ([cb isMemberOfClass: [FractionBarLayer class]]) {
            FractionBarLayer *bar = cb;
            CALayer *layer = [CALayer layer];
            layer.contentsScale = [UIScreen mainScreen].scale;
            layer.name = @"drawframe";
            layer.backgroundColor = [UIColor clearColor].CGColor;
            layer.frame = bar.frame;
            layer.delegate = vc;
            [view.layer addSublayer: layer];
            [layer setNeedsDisplay];
        }
        
        if ([cb isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *block = cb;
            drawFrame(vc, view, block);
        }
        
        if ([cb isMemberOfClass: [RadicalBlock class]]) {
            RadicalBlock *block = cb;
            CALayer *layer = [CALayer layer];
            layer.contentsScale = [UIScreen mainScreen].scale;
            layer.name = @"drawframe";
            layer.backgroundColor = [UIColor clearColor].CGColor;
            layer.frame = block.frame;
            layer.delegate = vc;
            [view.layer addSublayer: layer];
            [layer setNeedsDisplay];
            
            drawFrame(vc, view, block.content);
        }
        
        if ([cb isMemberOfClass: [WrapedEqTxtLyr class]]) {
            WrapedEqTxtLyr *wetl = cb;
            CALayer *layer = [CALayer layer];
            layer.contentsScale = [UIScreen mainScreen].scale;
            layer.name = @"drawframe";
            layer.backgroundColor = [UIColor clearColor].CGColor;
            layer.frame = wetl.mainFrame;
            layer.delegate = vc;
            [view.layer addSublayer: layer];
            [layer setNeedsDisplay];
            
            drawFrame(vc, view, wetl.content);
        }
        
        if ([cb isMemberOfClass: [Parentheses class]]) {
            Parentheses *p = cb;
            CALayer *layer = [CALayer layer];
            layer.contentsScale = [UIScreen mainScreen].scale;
            layer.name = @"drawframe";
            layer.backgroundColor = [UIColor clearColor].CGColor;
            layer.frame = p.frame;
            layer.delegate = vc;
            [view.layer addSublayer: layer];
            [layer setNeedsDisplay];
            
            if (p.expo != nil) {
                drawFrame(vc, view, p.expo);
            }
        }
    }
}

void drawStrLenTable(ViewController *vc, UIView *view, EquationTextLayer *etl) {
    CALayer *layer = [CALayer layer];
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.name = @"drawStrLenTable";
    layer.backgroundColor = [UIColor clearColor].CGColor;
    layer.frame = etl.frame;
    layer.delegate = vc;
    [view.layer addSublayer: layer];
    [layer setNeedsDisplay];
}


