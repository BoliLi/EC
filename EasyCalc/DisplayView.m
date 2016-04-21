//
//  DisplayView.m
//  EasyCalc
//
//  Created by LiBoli on 15/11/20.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#import "DisplayView.h"
#import "CalcBoard.h"
#import "Global.h"
#import "Equation.h"
#import "EquationBlock.h"
#import "EquationTextLayer.h"
#import "RadicalBlock.h"
#import "FractionBarLayer.h"
#import "WrapedEqTxtLyr.h"
#import "Parentheses.h"
#import "Utils.h"

@implementation DisplayView
@synthesize cursor;
@synthesize inpOrg;
@synthesize swipLBtn;
@synthesize swipRBtn;
@synthesize par;

-(id) init : (CalcBoard *)calcB : (CGRect)dspFrame : (ViewController *)vc {
    self = [super initWithFrame:dspFrame];
    if (self) {
        par = calcB;
        
        self.backgroundColor = [UIColor lightGrayColor];
        self.contentSize = CGSizeMake(dspFrame.size.width * 5.0, dspFrame.size.height * 3.0);
        self.directionalLockEnabled = YES;
        self.bounces = YES;
        [self setContentOffset:CGPointMake(0, dspFrame.size.height * 2.0) animated:NO];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:vc action:@selector(handleTap:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:tapGesture];
        
//        swipLBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//        swipLBtn.titleLabel.font = [UIFont systemFontOfSize: 30];
//        swipLBtn.showsTouchWhenHighlighted = YES;
//        [swipLBtn setTitle:@"<" forState:UIControlStateNormal];
//        swipLBtn.frame = CGRectMake(0, dspFrame.size.height / 2.0, 20, 20);
//        [swipLBtn addTarget:vc action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:swipLBtn];
//        
//        swipRBtn = [UIButton buttonWithType:UIButtonTypeSystem];
//        swipRBtn.titleLabel.font = [UIFont systemFontOfSize: 30];
//        swipRBtn.showsTouchWhenHighlighted = YES;
//        [swipRBtn setTitle:@">" forState:UIControlStateNormal];
//        swipRBtn.frame = CGRectMake(dspFrame.size.width - 20, dspFrame.size.height / 2.0, 20, 20);
//        [swipRBtn addTarget:vc action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:swipRBtn];
        
        CGPoint rootPos = CGPointMake(calcB.downLeftBasePoint.x, calcB.downLeftBasePoint.y - calcB.curFontH - 1.0);
        
        CALayer *clayer = [CALayer layer];
        clayer.contentsScale = [UIScreen mainScreen].scale;
        clayer.name = @"cursorLayer";
        clayer.hidden = NO;
        clayer.backgroundColor = [UIColor clearColor].CGColor;
        clayer.frame = CGRectMake(rootPos.x, rootPos.y, 3.0, calcB.curFontH);
        clayer.delegate = vc;
        [self.layer addSublayer:clayer];
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"hidden"];
        anim.fromValue = [NSNumber numberWithBool:YES];
        anim.toValue = [NSNumber numberWithBool:NO];
        anim.duration = 0.5;
        anim.autoreverses = YES;
        anim.repeatCount = HUGE_VALF;
        [clayer addAnimation:anim forKey:nil];
        [clayer setNeedsDisplay];
        
        self.cursor = clayer;
        self.inpOrg = clayer.frame.origin;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.cursor = [coder decodeObjectForKey:@"cursor"];
        self.inpOrg = [coder decodeCGPointForKey:@"inpOrg"];
        self.swipLBtn = [coder decodeObjectForKey:@"swipLBtn"];
        self.swipRBtn = [coder decodeObjectForKey:@"swipRBtn"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:self.cursor forKey:@"cursor"];
    [coder encodeCGPoint:self.inpOrg forKey:@"inpOrg"];
    [coder encodeObject:self.swipLBtn forKey:@"swipLBtn"];
    [coder encodeObject:self.swipRBtn forKey:@"swipRBtn"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect bouds = [self bounds];
    CGFloat maxX = CGRectGetMaxX(bouds);
    CGFloat minX = CGRectGetMinX(bouds);
    CGFloat midY = CGRectGetMidY(bouds);
    
    swipLBtn.frame = CGRectMake(minX, midY, 20, 20);
    swipRBtn.frame = CGRectMake(maxX - 20, midY, 20, 20);
}

- (void)updateContentView {
    if (!CGRectContainsPoint(self.bounds, self.inpOrg)) {
        CGFloat offX = self.inpOrg.x - self.bounds.size.width;
        
        if (offX < 0.0)
            [self setContentOffset:CGPointMake(0.0, self.bounds.size.height * 2.0) animated:YES];
        else
            [self setContentOffset:CGPointMake(offX + 20.0, self.bounds.size.height * 2.0) animated:YES];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
