//
//  ViewController.m
//  EasyCalc
//
//  Created by LiBoli on 15/11/20.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Easing.h"
#import "Global.h"
#import "Utils.h"
#import "Equation.h"
#import "EquationBlock.h"
#import "EquationTextLayer.h"
#import "RadicalBlock.h"
#import "FractionBarLayer.h"
#import "WrapedEqTxtLyr.h"
#import "Parentheses.h"

static UIView *testview;

@interface ViewController ()

@end

@implementation ViewController
@synthesize mainKbView;
@synthesize secondKbView;
@synthesize kbConView;
@synthesize dspConView;
@synthesize borderLayer;
@synthesize scnWidth;
@synthesize scnHeight;
@synthesize statusBarHeight;
@synthesize testeb;
@synthesize delBtnLongPressTmr;

-(void)handleTap: (UITapGestureRecognizer *)gesture {
    //NSUInteger touchNum = [gesture numberOfTouches];
    //NSUInteger tapNum = [gesture numberOfTapsRequired];
    CGPoint curPoint = [gesture locationOfTouch:0 inView: gCurE.view];
    NSLog(@"%s%i~[%.1f, %.1f]~~~~~~~~~~", __FUNCTION__, __LINE__, curPoint.x, curPoint.y);
    id b = [gCurE lookForElementByPoint:gCurE.root :curPoint];
    if (b != nil) {
        cfgEqnBySlctBlk(gCurE, b, curPoint);
    } else { //Tap outside
        if (gCurE.root.children.count != 0) {
            
            gCurE.curFont = gCurE.baseFont;
            
            if (gCurE.root.bar != nil) {//Root block has denominator
                CGFloat tmp = gCurE.root.mainFrame.size.height;
                gCurE.view.cursor.frame = CGRectMake(gCurE.root.mainFrame.origin.x + gCurE.root.mainFrame.size.width, gCurE.root.mainFrame.origin.y, CURSOR_W, tmp);
                CGFloat x = gCurE.root.bar.frame.origin.x + gCurE.root.bar.frame.size.width;
                CGFloat y = gCurE.root.numerFrame.origin.y + gCurE.root.numerFrame.size.height - gCurE.curFontH / 2.0;
                gCurE.view.inpOrg = CGPointMake(x, y);
                gCurE.curMode = MODE_DUMP_ROOT;
                gCurE.curTxtLyr = nil;
                gCurE.curBlk = gCurE.root;
                gCurE.curRoll = ROLL_NUMERATOR;
                gCurE.insertCIdx = gCurE.root.c_idx + 1;
            } else {
                id block = [gCurE.root.children lastObject];
                if ([block isMemberOfClass: [EquationTextLayer class]]) {
                    EquationTextLayer *layer = block;
                    
                    gCurE.curMode = MODE_INPUT;
                    
                    if (layer.type == TEXTLAYER_OP) {
                        CGFloat x = layer.frame.origin.x + layer.frame.size.width;
                        CGFloat y = layer.frame.origin.y;
                        gCurE.view.inpOrg = CGPointMake(x, y);
                        CGFloat tmp = layer.frame.size.height;
                        gCurE.view.cursor.frame = CGRectMake(gCurE.view.inpOrg.x, gCurE.view.inpOrg.y, CURSOR_W, tmp);
                        gCurE.curTxtLyr = nil;
                    } else if (layer.type == TEXTLAYER_NUM) {
                        if (layer.expo == nil) {
                            CGFloat x = layer.frame.origin.x + layer.frame.size.width;
                            CGFloat y = layer.frame.origin.y;
                            gCurE.view.inpOrg = CGPointMake(x, y);
                            CGFloat tmp = layer.frame.size.height;
                            gCurE.view.cursor.frame = CGRectMake(gCurE.view.inpOrg.x, gCurE.view.inpOrg.y, CURSOR_W, tmp);
                            gCurE.curTxtLyr = layer;
                        } else {
                            CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                            CGFloat y = layer.frame.origin.y;
                            gCurE.view.inpOrg = CGPointMake(x, y);
                            CGFloat tmp = layer.mainFrame.size.height;
                            gCurE.view.cursor.frame = CGRectMake(gCurE.view.inpOrg.x, layer.mainFrame.origin.y, CURSOR_W, tmp);
                            gCurE.curTxtLyr = nil;
                        }
                    } else if (layer.type == TEXTLAYER_EMPTY) {
                        if (layer.expo == nil) {
                            CGFloat x = layer.frame.origin.x;
                            CGFloat y = layer.frame.origin.y;
                            gCurE.view.inpOrg = CGPointMake(x, y);
                            CGFloat tmp = layer.frame.size.height;
                            gCurE.view.cursor.frame = CGRectMake(gCurE.view.inpOrg.x, gCurE.view.inpOrg.y, CURSOR_W, tmp);
                            gCurE.curTxtLyr = layer;
                        } else {
                            CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                            CGFloat y = layer.frame.origin.y;
                            gCurE.view.inpOrg = CGPointMake(x, y);
                            CGFloat tmp = layer.mainFrame.size.height;
                            gCurE.view.cursor.frame = CGRectMake(gCurE.view.inpOrg.x, layer.mainFrame.origin.y, CURSOR_W, tmp);
                            gCurE.curTxtLyr = nil;
                        }
                    } else
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    gCurE.curRoll = layer.roll;
                    gCurE.curParent = layer.parent;
                    gCurE.curBlk = layer;
                    gCurE.insertCIdx = layer.c_idx + 1;
                } else if ([block isMemberOfClass: [EquationBlock class]]) {
                    EquationBlock *b = block;
                    gCurE.curMode = MODE_INPUT;
                    gCurE.curParent = b.parent;
                    gCurE.curRoll = b.roll;
                    gCurE.curTxtLyr = nil;
                    gCurE.curBlk = b;
                    gCurE.insertCIdx = b.c_idx + 1;
                    CGFloat x = b.bar.frame.origin.x + b.bar.frame.size.width;
                    CGFloat y = b.numerFrame.origin.y + b.numerFrame.size.height - gCurE.curFontH / 2.0;
                    gCurE.view.inpOrg = CGPointMake(x, y);
                    CGFloat tmp = b.mainFrame.size.height;
                    gCurE.view.cursor.frame = CGRectMake(gCurE.view.inpOrg.x, b.mainFrame.origin.y, CURSOR_W, tmp);
                } else if ([block isMemberOfClass: [RadicalBlock class]]) {
                    RadicalBlock *b = block;
                    gCurE.curMode = MODE_INPUT;
                    gCurE.curParent = b.parent;
                    gCurE.curRoll = b.roll;
                    gCurE.curTxtLyr = nil;
                    gCurE.curBlk = b;
                    gCurE.insertCIdx = b.c_idx + 1;
                    CGFloat x = b.frame.origin.x + b.frame.size.width;
                    CGFloat y = b.frame.origin.y + b.frame.size.height / 2.0 - gCurE.curFontH / 2.0;
                    gCurE.view.inpOrg = CGPointMake(x, y);
                    CGFloat tmp = b.frame.size.height;
                    gCurE.view.cursor.frame = CGRectMake(gCurE.view.inpOrg.x, b.frame.origin.y, CURSOR_W, tmp);
                } else if ([block isMemberOfClass: [WrapedEqTxtLyr class]]) {
                    WrapedEqTxtLyr *wetl = block;
                    gCurE.curMode = MODE_INPUT;
                    gCurE.curParent = wetl.parent;
                    gCurE.curRoll = wetl.roll;
                    gCurE.curTxtLyr = nil;
                    gCurE.curBlk = wetl;
                    gCurE.insertCIdx = wetl.c_idx + 1;
                    CGFloat x = wetl.mainFrame.origin.x + wetl.mainFrame.size.width;
                    CGFloat y = wetl.mainFrame.origin.y + wetl.mainFrame.size.height / 2.0 - gCurE.curFontH / 2.0;
                    gCurE.view.inpOrg = CGPointMake(x, y);
                    gCurE.view.cursor.frame = CGRectMake(x, wetl.mainFrame.origin.y, CURSOR_W, wetl.mainFrame.size.height);
                } else if ([block isMemberOfClass: [Parentheses class]]) {
                    Parentheses *p = block;
                    gCurE.curMode = MODE_INPUT;
                    gCurE.curParent = p.parent;
                    gCurE.curRoll = p.roll;
                    gCurE.curTxtLyr = nil;
                    gCurE.curBlk = p;
                    gCurE.insertCIdx = p.c_idx + 1;
                    CGFloat x = p.frame.origin.x + p.frame.size.width;
                    CGFloat y = p.frame.origin.y + p.frame.size.height / 2.0 - gCurE.curFontH / 2.0;
                    gCurE.view.inpOrg = CGPointMake(x, y);
                    CGFloat tmp = p.frame.size.height;
                    gCurE.view.cursor.frame = CGRectMake(gCurE.view.inpOrg.x, p.frame.origin.y, CURSOR_W, tmp);
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
            }
        }
    }
}

-(void)handleDspViewSwipeRight: (UISwipeGestureRecognizer *)gesture {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:gCurE];
    [user setObject:data forKey:[NSString stringWithFormat:@"equation%li", (long)gCurEqIdx]];
    
    DisplayView *orgView = gCurE.view;
    gCurEqIdx--;
    if (gCurEqIdx < 0) {
        gCurEqIdx = 15;
    }
    gCurE = [gEquationList objectAtIndex:gCurEqIdx];
    [gCurE.view.cursor removeAllAnimations];
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"hidden"];
    anim.fromValue = [NSNumber numberWithBool:YES];
    anim.toValue = [NSNumber numberWithBool:NO];
    anim.duration = 0.5;
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VALF;
    [gCurE.view.cursor addAnimation:anim forKey:nil];
    [UIView transitionFromView:orgView toView:gCurE.view duration:0.4 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
        // What to do when its finished.
    }];
}

-(void)handleDspViewSwipeLeft: (UISwipeGestureRecognizer *)gesture {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:gCurE];
    [user setObject:data forKey:[NSString stringWithFormat:@"equation%li", (long)gCurEqIdx]];
    
    DisplayView *orgView = gCurE.view;
    gCurEqIdx++;
    gCurEqIdx %= 16;
    gCurE = [gEquationList objectAtIndex:gCurEqIdx];
    [gCurE.view.cursor removeAllAnimations];
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"hidden"];
    anim.fromValue = [NSNumber numberWithBool:YES];
    anim.toValue = [NSNumber numberWithBool:NO];
    anim.duration = 0.5;
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VALF;
    [gCurE.view.cursor addAnimation:anim forKey:nil];
    [UIView transitionFromView:orgView toView:gCurE.view duration:0.4 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
        // What to do when its finished.
    }];
}

-(void)handleKbViewSwipeRight: (UISwipeGestureRecognizer *)gesture {
    mainKbView.frame = CGRectMake(-scnWidth, 0, scnWidth, scnHeight / 2);
    mainKbView.alpha = 1.0;
    mainKbView.hidden = NO;
    [kbConView addSubview:mainKbView];
    
    [UIView animateWithDuration:.5 animations:^{
        
        [mainKbView setEasingFunction:CreateCAMediaTimingFunction(0.175, 0.885, 0.52, 1.25) forKeyPath:@"center"];
        secondKbView.alpha = 0.0;
        mainKbView.frame = CGRectOffset(mainKbView.frame, scnWidth, 0);
        
    } completion:^(BOOL finished) {
        [mainKbView removeEasingFunctionForKeyPath:@"center"];
        
    }];
}

-(void)handleKbViewSwipeLeft: (UISwipeGestureRecognizer *)gesture {
    secondKbView.frame = CGRectMake(scnWidth, 0, scnWidth, scnHeight / 2);
    secondKbView.alpha = 1.0;
    secondKbView.hidden = NO;
    [kbConView addSubview:secondKbView];
    
    [UIView animateWithDuration:.5 animations:^{
        
        [secondKbView setEasingFunction:CreateCAMediaTimingFunction(0.175, 0.885, 0.52, 1.25) forKeyPath:@"center"];
        mainKbView.alpha = 0.0;
        secondKbView.frame = CGRectOffset(secondKbView.frame, -scnWidth, 0);
        
    } completion:^(BOOL finished) {
        [secondKbView removeEasingFunctionForKeyPath:@"center"];
        
    }];
}

- (void)backGroundInit: (Equation *)firstE {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //Do background work
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSString *ver = [user stringForKey:@"version"];
        if (ver != nil) {
            for (int i = 0; i < 16; i++) {
                if (i == gCurEqIdx) {
                    [gEquationList addObject:firstE];
                    continue;
                }
                Equation *eq = [NSKeyedUnarchiver unarchiveObjectWithData:[user objectForKey:[NSString stringWithFormat: @"equation%li", (long)i]]];
                [eq.root reorganize:eq :self];
                
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
                tapGesture.numberOfTapsRequired = 1;
                tapGesture.numberOfTouchesRequired = 1;
                [eq.view addGestureRecognizer:tapGesture];
                
                UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDspViewSwipeRight:)];
                right.numberOfTouchesRequired = 1;
                right.direction = UISwipeGestureRecognizerDirectionRight;
                [eq.view addGestureRecognizer:right];
                
                UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDspViewSwipeLeft:)];
                left.numberOfTouchesRequired = 1;
                left.direction = UISwipeGestureRecognizerDirectionLeft;
                [eq.view addGestureRecognizer:left];
                
                [eq.view.layer addSublayer:eq.view.cursor];
                eq.view.cursor.delegate = self;
                [eq.view.cursor setNeedsDisplay];
                [gEquationList addObject:eq];
            }
        } else {
            [user setObject:@"1.0" forKey:@"version"];
            [user setInteger:gCurEqIdx forKey:@"gCurEqIdx"];
            
            [gEquationList addObject:firstE];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:firstE];
            [user setObject:data forKey:@"equation0"];
            
            CGRect dspFrame = CGRectMake(0, 0, scnWidth, (scnHeight / 2) - statusBarHeight);
            CGPoint downLeft = CGPointMake(1, (scnHeight / 2) - statusBarHeight);
            for (int i = 1; i < 16; i++) {
                Equation *eq = [[Equation alloc] init:downLeft :dspFrame :self];
                [gEquationList addObject:eq];
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:eq];
                [user setObject:data forKey:[NSString stringWithFormat:@"equation%li", (long)i]];
            }
            NSLog(@"%s%i>~%i~~~~~~~~~~", __FUNCTION__, __LINE__, [user synchronize]);
        }
        
        secondKbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scnWidth, scnHeight / 2)];
        secondKbView.backgroundColor = [UIColor whiteColor];
        
        UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleKbViewSwipeRight:)];
        right.numberOfTouchesRequired = 1;
        right.direction = UISwipeGestureRecognizerDirectionRight;
        [secondKbView addGestureRecognizer:right];
        
        UIFont *buttonFont = [UIFont systemFontOfSize: 30];
        NSArray *btnTitleArr = [NSArray arrayWithObjects:@"save", @"load", @"reset", @"C", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", nil];
        CGFloat btnHeight = scnHeight / 10;
        CGFloat btnWidth = scnWidth / 5;
        for (int i = 0; i < 25; i++) {
            UIButton *bn = [UIButton buttonWithType:UIButtonTypeSystem];
            bn.tag = i + 10;
            bn.titleLabel.font = buttonFont;
            bn.showsTouchWhenHighlighted = YES;
            [bn setTitle:[btnTitleArr objectAtIndex:i] forState:UIControlStateNormal];
            int j = i % 5;
            int k = i / 5;
            bn.frame = CGRectMake(j * btnWidth, k * btnHeight, btnWidth, btnHeight);
            [bn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [secondKbView addSubview:bn];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //Update UI
            
        });
        
    });
    
}

- (void)foreGroundInit: (Equation *)firstE {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *ver = [user stringForKey:@"version"];
#if 0
    if (ver != nil) {
#else
    if (0) {
#endif
        for (int i = 0; i < 16; i++) {
            if (i == gCurEqIdx) {
                [gEquationList addObject:firstE];
                continue;
            }
            Equation *eq = [NSKeyedUnarchiver unarchiveObjectWithData:[user objectForKey:[NSString stringWithFormat: @"equation%li", (long)i]]];
            [eq.root reorganize:eq :self];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
            tapGesture.numberOfTapsRequired = 1;
            tapGesture.numberOfTouchesRequired = 1;
            [eq.view addGestureRecognizer:tapGesture];
            
            UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDspViewSwipeRight:)];
            right.numberOfTouchesRequired = 1;
            right.direction = UISwipeGestureRecognizerDirectionRight;
            [eq.view addGestureRecognizer:right];
            
            UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDspViewSwipeLeft:)];
            left.numberOfTouchesRequired = 1;
            left.direction = UISwipeGestureRecognizerDirectionLeft;
            [eq.view addGestureRecognizer:left];
            
            [eq.view.layer addSublayer:eq.view.cursor];
            eq.view.cursor.delegate = self;
            [eq.view.cursor setNeedsDisplay];
            [gEquationList addObject:eq];
        }
    } else {
        [user setObject:@"1.0" forKey:@"version"];
        [user setInteger:gCurEqIdx forKey:@"gCurEqIdx"];
        
        [gEquationList addObject:firstE];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:firstE];
        [user setObject:data forKey:@"equation0"];
        
        CGRect dspFrame = CGRectMake(0, 0, scnWidth, (scnHeight / 2) - statusBarHeight);
        CGPoint downLeft = CGPointMake(1, (scnHeight / 2) - statusBarHeight);
        for (int i = 1; i < 16; i++) {
            Equation *eq = [[Equation alloc] init:downLeft :dspFrame :self];
            [gEquationList addObject:eq];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:eq];
            [user setObject:data forKey:[NSString stringWithFormat:@"equation%li", (long)i]];
        }
        NSLog(@"%s%i>~%i~~~~~~~~~~", __FUNCTION__, __LINE__, [user synchronize]);
    }
    
    secondKbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scnWidth, scnHeight / 2)];
    secondKbView.backgroundColor = [UIColor whiteColor];
    
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleKbViewSwipeRight:)];
    right.numberOfTouchesRequired = 1;
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [secondKbView addGestureRecognizer:right];
    
    UIFont *buttonFont = [UIFont systemFontOfSize: 30];
    NSArray *btnTitleArr = [NSArray arrayWithObjects:@"save", @"load", @"reset", @"C", @"COS", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", nil];
    CGFloat btnHeight = scnHeight / 10;
    CGFloat btnWidth = scnWidth / 5;
    for (int i = 0; i < 25; i++) {
        UIButton *bn = [UIButton buttonWithType:UIButtonTypeSystem];
        bn.tag = i + 10;
        bn.titleLabel.font = buttonFont;
        bn.showsTouchWhenHighlighted = YES;
        [bn setTitle:[btnTitleArr objectAtIndex:i] forState:UIControlStateNormal];
        int j = i % 5;
        int k = i / 5;
        bn.frame = CGRectMake(j * btnWidth, k * btnHeight, btnWidth, btnHeight);
        [bn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [secondKbView addSubview:bn];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    initCharWidthTbl();
    
    scnWidth = [UIScreen mainScreen].bounds.size.width;
    scnHeight = [UIScreen mainScreen].bounds.size.height;
    statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    dspConView = [[UIView alloc] initWithFrame:CGRectMake(0, statusBarHeight, scnWidth, (scnHeight / 2) - statusBarHeight)];
    dspConView.tag = 1;
    dspConView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:dspConView];
    
    CGRect dspFrame = CGRectMake(0, 0, scnWidth, (scnHeight / 2) - statusBarHeight);
    CGPoint downLeft = CGPointMake(1, (scnHeight / 2) - statusBarHeight);
    //CGRect cursorFrame = CGRectMake(1, rootPos.y, 0.0, 0.0); //Size will update in Equation init
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *ver = [user stringForKey:@"version"];
#if 0
    if (ver != nil) {
#else
    if (0) {
#endif
        NSLog(@"%s%i>~~~~~~~~~~~", __FUNCTION__, __LINE__);
        gCurEqIdx = [user integerForKey:@"gCurEqIdx"];
        gCurE = [NSKeyedUnarchiver unarchiveObjectWithData:[user objectForKey:[NSString stringWithFormat: @"equation%li", (long)gCurEqIdx]]];
        [gCurE.root reorganize:gCurE :self];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [gCurE.view addGestureRecognizer:tapGesture];
        
        UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDspViewSwipeRight:)];
        right.numberOfTouchesRequired = 1;
        right.direction = UISwipeGestureRecognizerDirectionRight;
        [gCurE.view addGestureRecognizer:right];
        
        UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDspViewSwipeLeft:)];
        left.numberOfTouchesRequired = 1;
        left.direction = UISwipeGestureRecognizerDirectionLeft;
        [gCurE.view addGestureRecognizer:left];
        
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"hidden"];
        anim.fromValue = [NSNumber numberWithBool:YES];
        anim.toValue = [NSNumber numberWithBool:NO];
        anim.duration = 0.5;
        anim.autoreverses = YES;
        anim.repeatCount = HUGE_VALF;
        [gCurE.view.cursor addAnimation:anim forKey:nil];
        [gCurE.view.layer addSublayer:gCurE.view.cursor];
        gCurE.view.cursor.delegate = self;
        [gCurE.view.cursor setNeedsDisplay];
        
        [gCurE dumpEverything:gCurE.root];
    } else {
        NSLog(@"%s%i>~~~~~~~~~~~", __FUNCTION__, __LINE__);
//        for (int i = 0; i < 16; i++) {
//            gCurE = [[Equation alloc] init:downLeft :dspFrame :self];
//            [gEquationList addObject:gCurE];
//            //[dspConView addSubview:gCurE.view];
//        }
//        gCurE = gEquationList.firstObject;
        gCurE = [[Equation alloc] init:downLeft :dspFrame :self];
    }
    
    [self foreGroundInit:gCurE];
    
    [dspConView addSubview:gCurE.view];

    kbConView = [[UIView alloc] initWithFrame:CGRectMake(0, scnHeight / 2, scnWidth, scnHeight / 2)];
    kbConView.tag = 2;
    kbConView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:kbConView];
    
    mainKbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scnWidth, scnHeight / 2)];
    mainKbView.backgroundColor = [UIColor whiteColor];
    [kbConView addSubview:mainKbView];
    
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleKbViewSwipeLeft:)];
    left.numberOfTouchesRequired = 1;
    left.direction = UISwipeGestureRecognizerDirectionLeft;
    [mainKbView addGestureRecognizer:left];
    
    borderLayer = [CALayer layer];
    borderLayer.contentsScale = [UIScreen mainScreen].scale;
    borderLayer.name = @"btnBorderLayer";
    borderLayer.backgroundColor = [UIColor clearColor].CGColor;
    borderLayer.frame = CGRectMake(0, 0, scnWidth, scnHeight / 2);
    borderLayer.delegate = self;
    [mainKbView.layer addSublayer: borderLayer];
    [borderLayer setNeedsDisplay];
    
    UIFont *buttonFont = [UIFont systemFontOfSize: 30];
    NSArray *btnTitleArr = [NSArray arrayWithObjects:@"DUMP", @"DEBUG", @"Root", @"<-", @"7", @"8", @"9", @"÷", @"4", @"5", @"6", @"×", @"1", @"2", @"3", @"-", @"%", @"0", @"·", @"+", @"x^", @"(", @")", @"=", nil];
    CGFloat btnHeight = scnHeight / 10;
    CGFloat btnWidth = scnWidth / 5;
    for (int i = 0; i < 20; i++) {
        UIButton *bn = [UIButton buttonWithType:UIButtonTypeSystem];
        bn.tag = i + 10;
        bn.titleLabel.font = buttonFont;
        bn.showsTouchWhenHighlighted = YES;
        [bn setTitle:[btnTitleArr objectAtIndex:i] forState:UIControlStateNormal];
        int j = i % 4;
        int k = i / 4;
        bn.frame = CGRectMake(j * btnWidth, k * btnHeight, btnWidth, btnHeight);
        [bn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 3) {
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(btnDelLongPress:)];
            longPress.minimumPressDuration = 1; //定义按的时间
            [bn addGestureRecognizer:longPress];
        }
        [mainKbView addSubview:bn];
    }
    
    for (int i = 20; i < 23; i++) {
        UIButton *bn = [UIButton buttonWithType:UIButtonTypeSystem];
        bn.tag = i + 10;
        bn.titleLabel.font = buttonFont;
        bn.showsTouchWhenHighlighted = YES;
        [bn setTitle:[btnTitleArr objectAtIndex:i] forState:UIControlStateNormal];
        int k = i % 4;
        bn.frame = CGRectMake(4 * btnWidth, k * btnHeight, btnWidth, btnHeight);
        [bn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [mainKbView addSubview:bn];
    }
    
    UIButton *bn = [UIButton buttonWithType:UIButtonTypeSystem];
    bn.tag = 33;
    bn.titleLabel.font = buttonFont;
    bn.showsTouchWhenHighlighted = YES;
    [bn setTitle:[btnTitleArr objectAtIndex: 23] forState:UIControlStateNormal];
    bn.frame = CGRectMake(4 * btnWidth, 3 * btnHeight, btnWidth, 2 * btnHeight);
    [bn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [mainKbView addSubview:bn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleNumBtnClick : (NSString *)num {
    CGFloat incrWidth = 0.0;
    CGFloat cursorOffset = 0.0;
    BOOL needNewLayer;
    
    if (gCurE.curTxtLyr == nil) {
        if ([gCurE.curBlk isMemberOfClass:[EquationBlock class]]) {
            EquationBlock *eb = gCurE.curBlk;
            if ([eb.parent isMemberOfClass:[RadicalBlock class]]) {
                needNewLayer = YES;
            } else if ([eb.parent isMemberOfClass:[WrapedEqTxtLyr class]]) {
                needNewLayer = YES;
            } else if ([eb.parent isMemberOfClass:[EquationBlock class]]) {
                EquationBlock *par = eb.parent;
                if (gCurE.insertCIdx == eb.c_idx) {
                    if (eb.c_idx == 0) {
                        needNewLayer = YES;
                    } else {
                        id b = [par.children objectAtIndex:eb.c_idx - 1];
                        if ([b isMemberOfClass:[EquationTextLayer class]]) {
                            EquationTextLayer *l = b;
                            if (l.type == TEXTLAYER_NUM) {
                                if (l.expo == nil) {
                                    needNewLayer = NO;
                                    cfgEqnBySlctBlk(gCurE, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                                } else {
                                    needNewLayer = YES;
                                }
                            } else {
                                needNewLayer = YES;
                            }
                        } else {
                            needNewLayer = YES;
                        }
                    }
                } else if (gCurE.insertCIdx == eb.c_idx + 1) {
                    if (eb.c_idx == par.children.count - 1) {
                        needNewLayer = YES;
                    } else {
                        id b = [par.children objectAtIndex:eb.c_idx + 1];
                        if ([b isMemberOfClass:[EquationTextLayer class]]) {
                            EquationTextLayer *l = b;
                            if (l.type == TEXTLAYER_NUM) {
                                needNewLayer = NO;
                                cfgEqnBySlctBlk(gCurE, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
                            } else {
                                needNewLayer = YES;
                            }
                        } else {
                            needNewLayer = YES;
                        }
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    return;
                }
            } else if (eb.roll == ROLL_ROOT) {
                needNewLayer = YES;
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
        } else if ([gCurE.curBlk isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *curLayer = gCurE.curBlk;
            EquationBlock *par = curLayer.parent;
            if (gCurE.insertCIdx == curLayer.c_idx) {
                if (curLayer.c_idx == 0) {
                    needNewLayer = YES;
                } else {
                    id b = [par.children objectAtIndex:curLayer.c_idx - 1];
                    if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        if (l.type == TEXTLAYER_NUM) {
                            if (l.expo == nil) {
                                needNewLayer = NO;
                                cfgEqnBySlctBlk(gCurE, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                            } else {
                                needNewLayer = YES;
                            }
                        } else {
                            needNewLayer = YES;
                        }
                    } else {
                        needNewLayer = YES;
                    }
                }
            } else if (gCurE.insertCIdx == curLayer.c_idx + 1) {
                if (curLayer.c_idx == par.children.count - 1) {
                    needNewLayer = YES;
                } else {
                    id b = [par.children objectAtIndex:curLayer.c_idx + 1];
                    if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        if (l.type == TEXTLAYER_NUM) {
                            needNewLayer = NO;
                            cfgEqnBySlctBlk(gCurE, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
                        } else {
                            needNewLayer = YES;
                        }
                    } else {
                        needNewLayer = YES;
                    }
                }
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
        } else if ([gCurE.curBlk isMemberOfClass:[FractionBarLayer class]]) {
            needNewLayer = YES;
        } else if ([gCurE.curBlk isMemberOfClass:[RadicalBlock class]]) {
            RadicalBlock *rb = gCurE.curBlk;
            EquationBlock *par = rb.parent;
            if (gCurE.insertCIdx == rb.c_idx) {
                if (rb.c_idx == 0) {
                    needNewLayer = YES;
                } else {
                    id b = [par.children objectAtIndex:rb.c_idx - 1];
                    if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        if (l.type == TEXTLAYER_NUM) {
                            if (l.expo == nil) {
                                needNewLayer = NO;
                                cfgEqnBySlctBlk(gCurE, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                            } else {
                                needNewLayer = YES;
                            }
                        } else {
                            needNewLayer = YES;
                        }
                    } else {
                        needNewLayer = YES;
                    }
                }
            } else if (gCurE.insertCIdx == rb.c_idx + 1) {
                if (rb.c_idx == par.children.count - 1) {
                    needNewLayer = YES;
                } else {
                    id b = [par.children objectAtIndex:rb.c_idx + 1];
                    if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        if (l.type == TEXTLAYER_NUM) {
                            needNewLayer = NO;
                            cfgEqnBySlctBlk(gCurE, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
                        } else {
                            needNewLayer = YES;
                        }
                    } else {
                        needNewLayer = YES;
                    }
                }
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
        } else if ([gCurE.curBlk isMemberOfClass:[WrapedEqTxtLyr class]]) {
            WrapedEqTxtLyr *wetl = gCurE.curBlk;
            EquationBlock *par = wetl.parent;
            if (gCurE.insertCIdx == wetl.c_idx) {
                if (wetl.c_idx == 0) {
                    needNewLayer = YES;
                } else {
                    id b = [par.children objectAtIndex:wetl.c_idx - 1];
                    if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        if (l.type == TEXTLAYER_NUM) {
                            if (l.expo == nil) {
                                needNewLayer = NO;
                                cfgEqnBySlctBlk(gCurE, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                            } else {
                                needNewLayer = YES;
                            }
                        } else {
                            needNewLayer = YES;
                        }
                    } else {
                        needNewLayer = YES;
                    }
                }
            } else if (gCurE.insertCIdx == wetl.c_idx + 1) {
                if (wetl.c_idx == par.children.count - 1) {
                    needNewLayer = YES;
                } else {
                    id b = [par.children objectAtIndex:wetl.c_idx + 1];
                    if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        if (l.type == TEXTLAYER_NUM) {
                            needNewLayer = NO;
                            cfgEqnBySlctBlk(gCurE, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
                        } else {
                            needNewLayer = YES;
                        }
                    } else {
                        needNewLayer = YES;
                    }
                }
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
        } else if ([gCurE.curBlk isMemberOfClass:[Parentheses class]]) {
            Parentheses *p = gCurE.curBlk;
            EquationBlock *par = p.parent;
            if (gCurE.insertCIdx == p.c_idx) {
                if (p.c_idx == 0) {
                    needNewLayer = YES;
                } else {
                    id b = [par.children objectAtIndex:p.c_idx - 1];
                    if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        if (l.type == TEXTLAYER_NUM) {
                            if (l.expo == nil) {
                                needNewLayer = NO;
                                cfgEqnBySlctBlk(gCurE, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                            } else {
                                needNewLayer = YES;
                            }
                        } else {
                            needNewLayer = YES;
                        }
                    } else {
                        needNewLayer = YES;
                    }
                }
            } else if (gCurE.insertCIdx == p.c_idx + 1) {
                if (p.c_idx == par.children.count - 1) {
                    needNewLayer = YES;
                } else {
                    id b = [par.children objectAtIndex:p.c_idx + 1];
                    if ([b isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = b;
                        if (l.type == TEXTLAYER_NUM) {
                            needNewLayer = NO;
                            cfgEqnBySlctBlk(gCurE, l, CGPointMake(l.frame.origin.x + 1.0, l.frame.origin.y + 1.0));
                        } else {
                            needNewLayer = YES;
                        }
                    } else {
                        needNewLayer = YES;
                    }
                }
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return;
        }
    } else {
        needNewLayer = NO;
    }
    
    if (needNewLayer) {
        
        EquationTextLayer *tLayer = [[EquationTextLayer alloc] init:num :gCurE.view.inpOrg :gCurE :TEXTLAYER_NUM];
        
        incrWidth = tLayer.frame.size.width;
        
        if(gCurE.curMode == MODE_INPUT) {
            EquationBlock *block = gCurE.curParent;

            tLayer.c_idx = block.children.count;
            [block.children addObject:tLayer];
        } else if(gCurE.curMode == MODE_INSERT) {
            EquationBlock *block = gCurE.curParent;

            tLayer.c_idx = gCurE.insertCIdx;
            [block.children insertObject:tLayer atIndex:tLayer.c_idx];
            /*Update c_idx*/
            [block updateCIdx];
        } else if(gCurE.curMode == MODE_DUMP_ROOT) {
            EquationBlock *newRoot = [[EquationBlock alloc] init:gCurE];
            newRoot.roll = ROLL_ROOT;
            newRoot.parent = nil;
            newRoot.numerFrame = gCurE.root.mainFrame;
            newRoot.numerTopHalf = gCurE.root.mainFrame.size.height / 2.0;
            newRoot.numerBtmHalf = gCurE.root.mainFrame.size.height / 2.0;
            newRoot.mainFrame = newRoot.numerFrame;
            gCurE.root.roll = ROLL_NUMERATOR;
            gCurE.root.parent = newRoot;
            if (gCurE.insertCIdx == 0) {
                tLayer.c_idx = 0;
                [newRoot.children addObject:tLayer];
                gCurE.root.c_idx = 1;
                [newRoot.children addObject:gCurE.root];
                gCurE.curMode = MODE_INSERT;
            } else {
                gCurE.root.c_idx = 0;
                [newRoot.children addObject:gCurE.root];
                tLayer.c_idx = 1;
                [newRoot.children addObject:tLayer];
                gCurE.curMode = MODE_INPUT;
            }
            gCurE.root = newRoot;
            gCurE.curParent = newRoot;
        } else if(gCurE.curMode == MODE_DUMP_RADICAL) {
            RadicalBlock *rBlock = gCurE.curParent;
            EquationBlock *orgRootRoot = rBlock.content;
            EquationBlock *newRootRoot = [[EquationBlock alloc] init:gCurE];
            newRootRoot.roll = ROLL_ROOT_ROOT;
            newRootRoot.parent = rBlock;
            newRootRoot.numerFrame = orgRootRoot.mainFrame;
            newRootRoot.numerTopHalf = orgRootRoot.mainFrame.size.height / 2.0;
            newRootRoot.numerBtmHalf = orgRootRoot.mainFrame.size.height / 2.0;
            newRootRoot.mainFrame = newRootRoot.numerFrame;
            orgRootRoot.roll = ROLL_NUMERATOR;
            orgRootRoot.parent = newRootRoot;
            if (gCurE.insertCIdx == 0) {
                tLayer.c_idx = 0;
                [newRootRoot.children addObject:tLayer];
                orgRootRoot.c_idx = 1;
                [newRootRoot.children addObject:orgRootRoot];
                gCurE.curMode = MODE_INSERT;
            } else {
                orgRootRoot.c_idx = 0;
                [newRootRoot.children addObject:orgRootRoot];
                tLayer.c_idx = 1;
                [newRootRoot.children addObject:tLayer];
                gCurE.curMode = MODE_INPUT;
            }
            rBlock.content = newRootRoot;
            gCurE.curParent = newRootRoot;
        } else if(gCurE.curMode == MODE_DUMP_EXPO) {
            EquationTextLayer *layer = gCurE.curParent;
            EquationBlock *orgExpo = layer.expo;
            EquationBlock *newExpo = [[EquationBlock alloc] init:gCurE];
            newExpo.roll = ROLL_EXPO_ROOT;
            newExpo.parent = layer;
            newExpo.numerFrame = orgExpo.mainFrame;
            newExpo.numerTopHalf = orgExpo.mainFrame.size.height / 2.0;
            newExpo.numerBtmHalf = orgExpo.mainFrame.size.height / 2.0;
            newExpo.mainFrame = newExpo.numerFrame;
            orgExpo.roll = ROLL_NUMERATOR;
            orgExpo.parent = newExpo;
            if (gCurE.insertCIdx == 0) {
                tLayer.c_idx = 0;
                [newExpo.children addObject:tLayer];
                orgExpo.c_idx = 1;
                [newExpo.children addObject:orgExpo];
                gCurE.curMode = MODE_INSERT;
            } else {
                orgExpo.c_idx = 0;
                [newExpo.children addObject:orgExpo];
                tLayer.c_idx = 1;
                [newExpo.children addObject:tLayer];
                gCurE.curMode = MODE_INPUT;
            }
            layer.expo = newExpo;
            gCurE.curParent = newExpo;
        } else if(gCurE.curMode == MODE_DUMP_WETL) {
            WrapedEqTxtLyr *wetl = gCurE.curParent;
            EquationBlock *orgWrapRoot = wetl.content;
            EquationBlock *newWrapRoot = [[EquationBlock alloc] init:gCurE];
            newWrapRoot.roll = ROLL_WRAP_ROOT;
            newWrapRoot.parent = wetl;
            newWrapRoot.numerFrame = orgWrapRoot.mainFrame;
            newWrapRoot.numerTopHalf = orgWrapRoot.mainFrame.size.height / 2.0;
            newWrapRoot.numerBtmHalf = orgWrapRoot.mainFrame.size.height / 2.0;
            newWrapRoot.mainFrame = newWrapRoot.numerFrame;
            orgWrapRoot.roll = ROLL_NUMERATOR;
            orgWrapRoot.parent = newWrapRoot;
            if (gCurE.insertCIdx == 0) {
                tLayer.c_idx = 0;
                [newWrapRoot.children addObject:tLayer];
                orgWrapRoot.c_idx = 1;
                [newWrapRoot.children addObject:orgWrapRoot];
                gCurE.curMode = MODE_INSERT;
            } else {
                orgWrapRoot.c_idx = 0;
                [newWrapRoot.children addObject:orgWrapRoot];
                tLayer.c_idx = 1;
                [newWrapRoot.children addObject:tLayer];
                gCurE.curMode = MODE_INPUT;
            }
            wetl.content = newWrapRoot;
            gCurE.curParent = newWrapRoot;
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        tLayer.parent = gCurE.curParent;
        [gCurE.view.layer addSublayer:tLayer];
        
        gCurE.insertCIdx = tLayer.c_idx + 1;
        gCurE.curTxtLyr = tLayer;
        gCurE.curBlk = tLayer;
        gCurE.txtInsIdx = 1;
        cursorOffset = tLayer.mainFrame.size.width;
    } else {
        if (gCurE.curTxtLyr.type == TEXTLAYER_EMPTY) {
            CGFloat orgW = gCurE.curTxtLyr.mainFrame.size.width;
            cursorOffset = [gCurE.curTxtLyr addNumChar:num];
            incrWidth += gCurE.curTxtLyr.mainFrame.size.width - orgW;
            gCurE.txtInsIdx = 1;
            gCurE.insertCIdx = gCurE.curTxtLyr.c_idx + 1;
        } else {
            CGFloat orgW = gCurE.curTxtLyr.mainFrame.size.width;
            if (gCurE.txtInsIdx == gCurE.curTxtLyr.strLenTbl.count - 1) {
                cursorOffset = [gCurE.curTxtLyr addNumChar:num];
            } else {
                cursorOffset = [gCurE.curTxtLyr insertNumChar:num at:gCurE.txtInsIdx];
            }
            gCurE.txtInsIdx++;
            incrWidth += gCurE.curTxtLyr.mainFrame.size.width - orgW;
        }
        
    }
    
    /* Update frame info of current block */
    [(EquationBlock *)gCurE.curParent updateFrameWidth:incrWidth :gCurE.curRoll];
    [gCurE.root adjustElementPosition];
    
    /* Move cursor */
    CGFloat cursorOrgX = gCurE.curTxtLyr.frame.origin.x + cursorOffset;
    CGFloat cursorOrgY = gCurE.curTxtLyr.frame.origin.y;
    
    gCurE.view.cursor.frame = CGRectMake(cursorOrgX, cursorOrgY, CURSOR_W, gCurE.curFontH);
    gCurE.view.inpOrg = CGPointMake(cursorOrgX, cursorOrgY);
    
    if (gCurE.root.mainFrame.origin.x + gCurE.root.mainFrame.size.width > scnWidth && gCurE.zoomInLvl < 2) {
        gCurE.zoomInLvl++;
        [self zoom];
    }
    
    NSLog(@"%s%i>~%@~~~~~~~~~~", __FUNCTION__, __LINE__, [gCurE.curTxtLyr.string string]);
}

- (void)handleOpBtnClick : (NSString *)op {
    if ([op isEqual: @"×"] || [op isEqual: @"+"] || [op isEqual: @"-"]) {
        CGFloat incrWidth = 0.0;
        
        if (gCurE.curTxtLyr != nil && gCurE.curTxtLyr.type == TEXTLAYER_EMPTY) {
            if (gCurE.curTxtLyr.expo == nil) {
                EquationBlock *cb = gCurE.curParent;
                [gCurE.curTxtLyr destroy];
                [cb.children removeObjectAtIndex:gCurE.curTxtLyr.c_idx];
                [cb updateCIdx];
                incrWidth -= gCurE.curTxtLyr.mainFrame.size.width;
            } else if ([gCurE.curTxtLyr.expo.children.firstObject isMemberOfClass:[EquationTextLayer class]]) {
                EquationTextLayer *l = gCurE.curTxtLyr.expo.children.firstObject;
                if (l.type == TEXTLAYER_EMPTY) {
                    EquationBlock *cb = gCurE.curParent;
                    [gCurE.curTxtLyr destroy];
                    [cb.children removeObjectAtIndex:gCurE.curTxtLyr.c_idx];
                    [cb updateCIdx];
                    incrWidth -= gCurE.curTxtLyr.mainFrame.size.width;
                } else {
                    gCurE.curMode = MODE_INSERT;
                    gCurE.insertCIdx = gCurE.curTxtLyr.c_idx;
                }
            } else {
                gCurE.curMode = MODE_INSERT;
                gCurE.insertCIdx = gCurE.curTxtLyr.c_idx;
            }
        }
        
        EquationTextLayer *tLayer = [[EquationTextLayer alloc] init:op :gCurE.view.inpOrg :gCurE :TEXTLAYER_OP];
        
        incrWidth += tLayer.frame.size.width;
        
        if(gCurE.curMode == MODE_INPUT) {
            EquationBlock *block = gCurE.curParent;
            
            tLayer.c_idx = block.children.count;
            [block.children addObject:tLayer];
        } else if(gCurE.curMode == MODE_INSERT) {
            EquationBlock *block = gCurE.curParent;
            
            tLayer.c_idx = gCurE.insertCIdx;
            [block.children insertObject:tLayer atIndex:tLayer.c_idx];
            /*Update c_idx*/
            [block updateCIdx];
        } else if(gCurE.curMode == MODE_DUMP_ROOT) {
            EquationBlock *newRoot = [[EquationBlock alloc] init:gCurE];
            newRoot.roll = ROLL_ROOT;
            newRoot.parent = nil;
            newRoot.numerFrame = gCurE.root.mainFrame;
            newRoot.numerTopHalf = gCurE.root.mainFrame.size.height / 2.0;
            newRoot.numerBtmHalf = gCurE.root.mainFrame.size.height / 2.0;
            newRoot.mainFrame = newRoot.numerFrame;
            gCurE.root.roll = ROLL_NUMERATOR;
            gCurE.root.parent = newRoot;
            if (gCurE.insertCIdx == 0) {
                tLayer.c_idx = 0;
                [newRoot.children addObject:tLayer];
                gCurE.root.c_idx = 1;
                [newRoot.children addObject:gCurE.root];
                gCurE.curMode = MODE_INSERT;
            } else {
                gCurE.root.c_idx = 0;
                [newRoot.children addObject:gCurE.root];
                tLayer.c_idx = 1;
                [newRoot.children addObject:tLayer];
                gCurE.curMode = MODE_INPUT;
            }
            gCurE.root = newRoot;
            gCurE.curParent = newRoot;
        } else if(gCurE.curMode == MODE_DUMP_RADICAL) {
            RadicalBlock *rBlock = gCurE.curParent;
            EquationBlock *orgRootRoot = rBlock.content;
            EquationBlock *newRootRoot = [[EquationBlock alloc] init:gCurE];
            newRootRoot.roll = ROLL_ROOT_ROOT;
            newRootRoot.parent = rBlock;
            newRootRoot.numerFrame = orgRootRoot.mainFrame;
            newRootRoot.numerTopHalf = orgRootRoot.mainFrame.size.height / 2.0;
            newRootRoot.numerBtmHalf = orgRootRoot.mainFrame.size.height / 2.0;
            newRootRoot.mainFrame = newRootRoot.numerFrame;
            orgRootRoot.roll = ROLL_NUMERATOR;
            orgRootRoot.parent = newRootRoot;
            if (gCurE.insertCIdx == 0) {
                tLayer.c_idx = 0;
                [newRootRoot.children addObject:tLayer];
                orgRootRoot.c_idx = 1;
                [newRootRoot.children addObject:orgRootRoot];
                gCurE.curMode = MODE_INSERT;
            } else {
                orgRootRoot.c_idx = 0;
                [newRootRoot.children addObject:orgRootRoot];
                tLayer.c_idx = 1;
                [newRootRoot.children addObject:tLayer];
                gCurE.curMode = MODE_INPUT;
            }
            rBlock.content = newRootRoot;
            gCurE.curParent = newRootRoot;
        } else if(gCurE.curMode == MODE_DUMP_EXPO) {
            EquationTextLayer *layer = gCurE.curParent;
            EquationBlock *orgExpoRoot = layer.expo;
            EquationBlock *newExpoRoot = [[EquationBlock alloc] init:gCurE];
            newExpoRoot.roll = ROLL_EXPO_ROOT;
            newExpoRoot.parent = layer;
            newExpoRoot.numerFrame = orgExpoRoot.mainFrame;
            newExpoRoot.numerTopHalf = orgExpoRoot.mainFrame.size.height / 2.0;
            newExpoRoot.numerBtmHalf = orgExpoRoot.mainFrame.size.height / 2.0;
            newExpoRoot.mainFrame = newExpoRoot.numerFrame;
            orgExpoRoot.roll = ROLL_NUMERATOR;
            orgExpoRoot.parent = newExpoRoot;
            if (gCurE.insertCIdx == 0) {
                tLayer.c_idx = 0;
                [newExpoRoot.children addObject:tLayer];
                orgExpoRoot.c_idx = 1;
                [newExpoRoot.children addObject:orgExpoRoot];
                gCurE.curMode = MODE_INSERT;
            } else {
                orgExpoRoot.c_idx = 0;
                [newExpoRoot.children addObject:orgExpoRoot];
                tLayer.c_idx = 1;
                [newExpoRoot.children addObject:tLayer];
                gCurE.curMode = MODE_INPUT;
            }
            layer.expo = newExpoRoot;
            gCurE.curParent = newExpoRoot;
        } else if(gCurE.curMode == MODE_DUMP_WETL) {
            WrapedEqTxtLyr *wetl = gCurE.curParent;
            EquationBlock *orgWrapRoot = wetl.content;
            EquationBlock *newWrapRoot = [[EquationBlock alloc] init:gCurE];
            newWrapRoot.roll = ROLL_WRAP_ROOT;
            newWrapRoot.parent = wetl;
            newWrapRoot.numerFrame = orgWrapRoot.mainFrame;
            newWrapRoot.numerTopHalf = orgWrapRoot.mainFrame.size.height / 2.0;
            newWrapRoot.numerBtmHalf = orgWrapRoot.mainFrame.size.height / 2.0;
            newWrapRoot.mainFrame = newWrapRoot.numerFrame;
            orgWrapRoot.roll = ROLL_NUMERATOR;
            orgWrapRoot.parent = newWrapRoot;
            if (gCurE.insertCIdx == 0) {
                tLayer.c_idx = 0;
                [newWrapRoot.children addObject:tLayer];
                orgWrapRoot.c_idx = 1;
                [newWrapRoot.children addObject:orgWrapRoot];
                gCurE.curMode = MODE_INSERT;
            } else {
                orgWrapRoot.c_idx = 0;
                [newWrapRoot.children addObject:orgWrapRoot];
                tLayer.c_idx = 1;
                [newWrapRoot.children addObject:tLayer];
                gCurE.curMode = MODE_INPUT;
            }
            wetl.content = newWrapRoot;
            gCurE.curParent = newWrapRoot;
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        tLayer.parent = gCurE.curParent;
        [gCurE.view.layer addSublayer:tLayer];
        
        gCurE.insertCIdx = tLayer.c_idx + 1;
        gCurE.txtInsIdx = 1;
        gCurE.curTxtLyr = nil;
        gCurE.curBlk = tLayer;
        
        //Update frame info of current block */
        //dumpObj(gCurE.root);
        //NSLog(@"%s%i~%f~%@~~~~~~~~~", __FUNCTION__, __LINE__, strSize.width, gCurE.curRoll == ROLL_NUMERATOR?@"N":@"D");
        [(EquationBlock *)gCurE.curParent updateFrameWidth:incrWidth :gCurE.curRoll];
        [gCurE.root adjustElementPosition];
        
        /* Move cursor */
        CGFloat cursorOrgX = 0.0;
        CGFloat cursorOrgY = 0.0;
        cursorOrgX = tLayer.frame.origin.x + tLayer.frame.size.width;
        cursorOrgY = tLayer.frame.origin.y;
        gCurE.view.cursor.frame = CGRectMake(cursorOrgX, cursorOrgY, CURSOR_W, gCurE.curFontH);
        gCurE.view.inpOrg = CGPointMake(cursorOrgX, cursorOrgY);
        
        if (gCurE.root.mainFrame.origin.x + gCurE.root.mainFrame.size.width > scnWidth && gCurE.zoomInLvl < 2) {
            gCurE.zoomInLvl++;
            [self zoom];
        }
        NSLog(@"%s%i>~%@~~~~~~~~~~", __FUNCTION__, __LINE__, [tLayer.string string]);
    } else { //Handle "÷"
        if (gCurE.insertCIdx == 0) {
            return;
        }
        
        if ([gCurE.curParent isMemberOfClass: [EquationBlock class]]) {
            EquationBlock *par = gCurE.curParent;
            if (par.bar != nil) {
                if (par.bar.c_idx == gCurE.insertCIdx - 1) {
                    return;
                }
            }
        }
        
        if(gCurE.curMode == MODE_INPUT) {
            EquationBlock *eBlock = gCurE.curParent;
            NSMutableArray *blockChildren = eBlock.children;
            NSEnumerator *enumerator = [blockChildren reverseObjectEnumerator];
            id block;
            CGFloat frameW = 0.0;
            CGFloat frameH = 0.0;
            CGFloat frameX = 0.0;
            CGFloat frameY = 0.0;
            NSUInteger cnt = 0;
            CGFloat newNumerTop = 0.0, newNumerBtm = 0.0;
            if (gCurE.curRoll == ROLL_NUMERATOR) {
                frameY = eBlock.numerFrame.origin.y;
            } else if (gCurE.curRoll == ROLL_DENOMINATOR) {
                frameY = eBlock.denomFrame.origin.y;
            } else
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            
            int parenCnt = 0;
            while (block = [enumerator nextObject]) {
                if ([block isMemberOfClass: [EquationTextLayer class]]) {
                    EquationTextLayer *layer = block;
                    if (([layer.name isEqual: @"+"] || [layer.name isEqual: @"-"]) && parenCnt <= 0)
                        break;
                    
                    /* Move numerators */
                    layer.roll = ROLL_NUMERATOR;
                    frameW += layer.mainFrame.size.width;
                    frameX = layer.mainFrame.origin.x;
                    if (newNumerTop < layer.mainFrame.size.height - layer.frame.size.height / 2.0) {
                        newNumerTop = layer.mainFrame.size.height - layer.frame.size.height / 2.0;
                        frameY = layer.mainFrame.origin.y;
                    }
                    
                    if (newNumerBtm < layer.frame.size.height / 2.0) {
                        newNumerBtm = layer.frame.size.height / 2.0;
                    }
                }else if ([block isMemberOfClass: [FractionBarLayer class]]) {
                    break;
                }else if ([block isMemberOfClass: [EquationBlock class]]) {
                    EquationBlock *b = block;
                    b.roll = ROLL_NUMERATOR;
                    frameW += b.mainFrame.size.width;
                    frameX = b.mainFrame.origin.x;
                    if (newNumerTop < b.mainFrame.size.height / 2.0) {
                        newNumerTop = b.mainFrame.size.height / 2.0;
                        frameY = b.mainFrame.origin.y;
                    }
                    
                    if (newNumerBtm < b.mainFrame.size.height / 2.0) {
                        newNumerBtm = b.mainFrame.size.height / 2.0;
                    }
                }else if ([block isMemberOfClass: [RadicalBlock class]]) {
                    RadicalBlock *b = block;
                    b.roll = ROLL_NUMERATOR;
                    frameW += b.frame.size.width;
                    frameX = b.frame.origin.x;
                    if (newNumerTop < b.frame.size.height / 2.0) {
                        newNumerTop = b.frame.size.height / 2.0;
                        frameY = b.frame.origin.y;
                    }
                    
                    if (newNumerBtm < b.frame.size.height / 2.0) {
                        newNumerBtm = b.frame.size.height / 2.0;
                    }
                }else if ([block isMemberOfClass: [WrapedEqTxtLyr class]]) {
                    WrapedEqTxtLyr *wetl = block;
                    wetl.roll = ROLL_NUMERATOR;
                    frameW += wetl.mainFrame.size.width;
                    frameX = wetl.mainFrame.origin.x;
                    if (newNumerTop < wetl.mainFrame.size.height / 2.0) {
                        newNumerTop = wetl.mainFrame.size.height / 2.0;
                        frameY = wetl.mainFrame.origin.y;
                    }
                    
                    if (newNumerBtm < wetl.mainFrame.size.height / 2.0) {
                        newNumerBtm = wetl.mainFrame.size.height / 2.0;
                    }
                }else if ([block isMemberOfClass: [Parentheses class]]) {
                    Parentheses *p = block;
                    if (p.l_or_r == RIGHT_PARENTH)
                        parenCnt++;
                    else
                        parenCnt--;
                    
                    p.roll = ROLL_NUMERATOR;
                    frameW += p.frame.size.width;
                    frameX = p.frame.origin.x;
                    if (newNumerTop < p.frame.size.height / 2.0) {
                        newNumerTop = p.frame.size.height / 2.0;
                        frameY = p.frame.origin.y;
                    }
                    
                    if (newNumerBtm < p.frame.size.height / 2.0) {
                        newNumerBtm = p.frame.size.height / 2.0;
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
                
                cnt++;
            }
            
            if (cnt == 0) {
                return;
            }
            
            frameH = newNumerTop + newNumerBtm;
            
            if (block != nil) { // Need a new block
                EquationBlock *newBlock = [[EquationBlock alloc] init:gCurE];
                newBlock.roll = gCurE.curRoll;
                newBlock.parent = eBlock;
                newBlock.numerFrame = CGRectMake(frameX, frameY - gCurE.curFontH, frameW, frameH);
                newBlock.mainFrame = newBlock.numerFrame;
                newBlock.numerTopHalf = newNumerTop;
                newBlock.numerBtmHalf = newNumerBtm;
                /* The value of start had been double checked */
                NSUInteger start = blockChildren.count - cnt;
                /* Add potential numerators into new block */
                for (NSUInteger i = start; i < blockChildren.count; i++) {
                    block = [blockChildren objectAtIndex:i];
                    if ([block isMemberOfClass: [EquationTextLayer class]]) {
                        EquationTextLayer *layer = block;
                        layer.c_idx = newBlock.children.count;
                        layer.parent = newBlock;
                        [newBlock.children addObject:layer];
                    } else if ([block isMemberOfClass: [EquationBlock class]]) {
                        EquationBlock *b = block;
                        b.c_idx = newBlock.children.count;
                        b.parent = newBlock;
                        [newBlock.children addObject:b];
                    } else if ([block isMemberOfClass: [RadicalBlock class]]) {
                        RadicalBlock *b = block;
                        b.c_idx = newBlock.children.count;
                        b.parent = newBlock;
                        [newBlock.children addObject:b];
                    } else if ([block isMemberOfClass: [WrapedEqTxtLyr class]]) {
                        WrapedEqTxtLyr *b = block;
                        b.c_idx = newBlock.children.count;
                        b.parent = newBlock;
                        [newBlock.children addObject:b];
                    } else if ([block isMemberOfClass: [Parentheses class]]) {
                        Parentheses *p = block;
                        p.c_idx = newBlock.children.count;
                        p.parent = newBlock;
                        [newBlock.children addObject:p];
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                }
                /* Remove those elements from old block */
                [blockChildren removeObjectsInRange:NSMakeRange(start, cnt)];
                /* Add new block into parent block */
                newBlock.c_idx = blockChildren.count;
                [blockChildren addObject: newBlock];
                eBlock = newBlock;
            } else {
                eBlock.numerFrame = CGRectMake(frameX, frameY - gCurE.curFontH, frameW, frameH);
            }
            
            /* Make an empty denominator frame */
            eBlock.denomFrame = CGRectMake(frameX, frameY + frameH - gCurE.curFontH, 0, gCurE.curFontH);
            eBlock.denomTopHalf = gCurE.curFontH / 2.0;
            eBlock.denomBtmHalf = gCurE.curFontH / 2.0;
            eBlock.mainFrame = CGRectUnion(eBlock.numerFrame, eBlock.denomFrame);
            
            if (eBlock.parent != nil) {
                if ([eBlock.parent isMemberOfClass: [RadicalBlock class]]) {
                    RadicalBlock *rb = eBlock.parent;
                    CGFloat orgW = rb.frame.size.width;
                    [rb updateFrame];
                    [rb setNeedsDisplay];
                    if ([rb.parent isMemberOfClass:[EquationBlock class]]) {
                        [(EquationBlock *)rb.parent updateFrameHeightS1:rb];
                        [(EquationBlock *)rb.parent updateFrameWidth:rb.frame.size.width - orgW :rb.roll];
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else if ([eBlock.parent isMemberOfClass: [EquationTextLayer class]]) {
                    EquationTextLayer *layer = eBlock.parent;
                    [layer updateFrameBaseOnExpo];
                    if ([layer.parent isMemberOfClass:[EquationBlock class]]) {
                        [(EquationBlock *)layer.parent updateFrameHeightS1:layer];
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else if ([eBlock.parent isMemberOfClass: [EquationBlock class]]) {
                    [(EquationBlock *)eBlock.parent updateFrameHeightS1:eBlock];
                } else if ([eBlock.parent isMemberOfClass: [WrapedEqTxtLyr class]]) {
                    WrapedEqTxtLyr *wetl = eBlock.parent;
                    CGFloat orgW = wetl.mainFrame.size.width;
                    
                    [wetl updateFrame:YES];
                    
                    if ([wetl.parent isMemberOfClass:[EquationBlock class]]) {
                        [(EquationBlock *)wetl.parent updateFrameHeightS1:wetl];
                        [(EquationBlock *)wetl.parent updateFrameWidth:wetl.mainFrame.size.width - orgW :wetl.roll];
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
                
            }
            gCurE.curParent = eBlock;
        } else if(gCurE.curMode == MODE_INSERT) {
            if (gCurE.insertCIdx == 0) { // No division while no numerator
                return;
            }
            NSUInteger i = 0, cnt = 0;
            CGFloat frameW = 0.0;
            CGFloat frameH = 0.0;
            CGFloat frameX = 0.0;
            CGFloat frameY = 0.0;
            CGFloat newNumerTop = 0.0, newNumerBtm = 0.0;
            EquationBlock *eBlock = gCurE.curParent;
            EquationBlock *newBlock = [[EquationBlock alloc] init:gCurE];
            newBlock.roll = gCurE.curRoll;
            newBlock.parent = eBlock;
            
            int parenCnt = 0;
            int tmp = 0;
            for (int ii = (int)gCurE.insertCIdx - 1; ii >= 0; ii--) {
                i = ii;
                id block = [eBlock.children objectAtIndex:i];
                if ([block isMemberOfClass: [EquationTextLayer class]]) {
                    EquationTextLayer *layer = block;
                    if (([layer.name isEqual: @"+"] || [layer.name isEqual: @"-"]) && parenCnt <= 0) {
                        tmp = 1;
                        break;
                    }
                    
                    layer.roll = ROLL_NUMERATOR;
                    frameW += layer.mainFrame.size.width;
                    frameX = layer.frame.origin.x;
                    if (newNumerTop < layer.mainFrame.size.height - layer.frame.size.height / 2.0) {
                        newNumerTop = layer.mainFrame.size.height - layer.frame.size.height / 2.0;
                        frameY = layer.mainFrame.origin.y;
                    }
                    
                    if (newNumerBtm < layer.frame.size.height / 2.0) {
                        newNumerBtm = layer.frame.size.height / 2.0;
                    }
                    layer.parent = newBlock;
                    [newBlock.children addObject:layer];
                } else if ([block isMemberOfClass: [FractionBarLayer class]]) {
                    tmp = 1;
                    break;
                } else if ([block isMemberOfClass: [EquationBlock class]]) {
                    EquationBlock *b = block;
                    b.roll = ROLL_NUMERATOR;
                    frameW += b.mainFrame.size.width;
                    frameX = b.mainFrame.origin.x;
                    if (newNumerTop < b.mainFrame.size.height / 2.0) {
                        newNumerTop = b.mainFrame.size.height / 2.0;
                        frameY = b.mainFrame.origin.y;
                    }
                    
                    if (newNumerBtm < b.mainFrame.size.height / 2.0) {
                        newNumerBtm = b.mainFrame.size.height / 2.0;
                    }
                    b.parent = newBlock;
                    [newBlock.children addObject:b];
                } else if ([block isMemberOfClass: [RadicalBlock class]]) {
                    RadicalBlock *b = block;
                    b.roll = ROLL_NUMERATOR;
                    frameW += b.frame.size.width;
                    frameX = b.frame.origin.x;
                    if (newNumerTop < b.frame.size.height / 2.0) {
                        newNumerTop = b.frame.size.height / 2.0;
                        frameY = b.frame.origin.y;
                    }
                    
                    if (newNumerBtm < b.frame.size.height / 2.0) {
                        newNumerBtm = b.frame.size.height / 2.0;
                    }
                    b.parent = newBlock;
                    [newBlock.children addObject:b];
                } else if ([block isMemberOfClass: [WrapedEqTxtLyr class]]) {
                    WrapedEqTxtLyr *wetl = block;
                    wetl.roll = ROLL_NUMERATOR;
                    frameW += wetl.mainFrame.size.width;
                    frameX = wetl.mainFrame.origin.x;
                    if (newNumerTop < wetl.mainFrame.size.height / 2.0) {
                        newNumerTop = wetl.mainFrame.size.height / 2.0;
                        frameY = wetl.mainFrame.origin.y;
                    }
                    
                    if (newNumerBtm < wetl.mainFrame.size.height / 2.0) {
                        newNumerBtm = wetl.mainFrame.size.height / 2.0;
                    }
                    wetl.parent = newBlock;
                    [newBlock.children addObject:wetl];
                }else if ([block isMemberOfClass: [Parentheses class]]) {
                    Parentheses *p = block;
                    if (p.l_or_r == RIGHT_PARENTH)
                        parenCnt++;
                    else
                        parenCnt--;
                    
                    p.roll = ROLL_NUMERATOR;
                    frameW += p.frame.size.width;
                    frameX = p.frame.origin.x;
                    if (newNumerTop < p.frame.size.height / 2.0) {
                        newNumerTop = p.frame.size.height / 2.0;
                        frameY = p.frame.origin.y;
                    }
                    
                    if (newNumerBtm < p.frame.size.height / 2.0) {
                        newNumerBtm = p.frame.size.height / 2.0;
                    }
                    
                    p.parent = newBlock;
                    [newBlock.children addObject:p];
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
                cnt++;
            }
            
            if (cnt == 0) {
                return;
            }
            
            frameH = newNumerTop + newNumerBtm;
            
            i += tmp;
            
            newBlock.numerFrame = CGRectMake(frameX, frameY - gCurE.curFontH, frameW, frameH);
            newBlock.numerTopHalf = newNumerTop;
            newBlock.numerBtmHalf = newNumerBtm;
            newBlock.denomFrame = CGRectMake(frameX, frameY + frameH - gCurE.curFontH, 0, gCurE.curFontH); //Make an empty denominator frame
            newBlock.denomTopHalf = gCurE.curFontH / 2.0;
            newBlock.denomBtmHalf = gCurE.curFontH / 2.0;
            newBlock.mainFrame = CGRectUnion(newBlock.numerFrame, newBlock.denomFrame);

            [newBlock.children reverse];
            [newBlock updateCIdx];
            /* Remove those elements from old block */
            [eBlock.children removeObjectsInRange:NSMakeRange(i, cnt)];
            /* Add new block into parent block */
            [eBlock.children insertObject:newBlock atIndex:i];
            [eBlock updateCIdx];
            eBlock = newBlock;

            gCurE.curMode = MODE_INPUT;
            
            if (eBlock.parent != nil) {
                if ([eBlock.parent isMemberOfClass: [RadicalBlock class]]) {
                    RadicalBlock *rb = eBlock.parent;
                    CGFloat orgW = rb.frame.size.width;
                    [rb updateFrame];
                    [rb setNeedsDisplay];
                    if ([rb.parent isMemberOfClass:[EquationBlock class]]) {
                        [(EquationBlock *)rb.parent updateFrameHeightS1:rb];
                        [(EquationBlock *)rb.parent updateFrameWidth:rb.frame.size.width - orgW :rb.roll];
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else if ([eBlock.parent isMemberOfClass: [EquationTextLayer class]]) {
                    EquationTextLayer *layer = eBlock.parent;
                    [layer updateFrameBaseOnExpo];
                    if ([layer.parent isMemberOfClass:[EquationBlock class]]) {
                        [(EquationBlock *)layer.parent updateFrameHeightS1:layer];
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else if ([eBlock.parent isMemberOfClass: [EquationBlock class]]) {
                    [gCurE dumpEverything:gCurE.root];
                    [(EquationBlock *)eBlock.parent updateFrameHeightS1:eBlock];
                    [gCurE dumpEverything:gCurE.root];
                } else if ([eBlock.parent isMemberOfClass: [WrapedEqTxtLyr class]]) {
                    WrapedEqTxtLyr *wetl = eBlock.parent;
                    CGFloat orgW = wetl.mainFrame.size.width;
                    
                    [wetl updateFrame:YES];
                    
                    if ([wetl.parent isMemberOfClass:[EquationBlock class]]) {
                        [(EquationBlock *)wetl.parent updateFrameHeightS1:wetl];
                        [(EquationBlock *)wetl.parent updateFrameWidth:wetl.mainFrame.size.width - orgW :wetl.roll];
                    } else {
                        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
            }
            
            gCurE.curParent = eBlock;
        } else if(gCurE.curMode == MODE_DUMP_ROOT) {
            CGFloat frameW = 0.0;
            CGFloat frameH = 0.0;
            CGFloat frameX = 0.0;
            CGFloat frameY = 0.0;
            EquationBlock *newRoot = [[EquationBlock alloc] init:gCurE];
            newRoot.roll = ROLL_ROOT;
            newRoot.parent = nil;

            frameX = gCurE.root.mainFrame.origin.x;
            frameY = gCurE.root.mainFrame.origin.y - gCurE.curFontH;
            frameW = gCurE.root.mainFrame.size.width;
            frameH = gCurE.root.mainFrame.size.height;

            newRoot.numerFrame = CGRectMake(frameX, frameY, frameW, frameH);
            newRoot.numerTopHalf = frameH / 2.0;
            newRoot.numerBtmHalf = frameH / 2.0;
            newRoot.denomFrame = CGRectMake(frameX, frameY + frameH, 0, gCurE.baseCharHight); //Make an empty denominator frame
            newRoot.denomTopHalf = gCurE.curFontH / 2.0;
            newRoot.denomBtmHalf = gCurE.curFontH / 2.0;
            newRoot.mainFrame = CGRectUnion(newRoot.numerFrame, newRoot.denomFrame);

            gCurE.root.mainFrame = newRoot.numerFrame;
            gCurE.root.c_idx = 0;
            gCurE.root.parent = newRoot;
            gCurE.root.roll = ROLL_NUMERATOR;
            [newRoot.children addObject: gCurE.root];

            gCurE.root = newRoot;
            gCurE.curParent = newRoot;
            gCurE.curMode = MODE_INPUT;
        } else if(gCurE.curMode == MODE_DUMP_RADICAL) {
            CGFloat frameW = 0.0;
            CGFloat frameH = 0.0;
            CGFloat frameX = 0.0;
            CGFloat frameY = 0.0;
            RadicalBlock *rBlock = gCurE.curParent;
            EquationBlock *orgRootRoot = rBlock.content;
            EquationBlock *newRootRoot = [[EquationBlock alloc] init:gCurE];
            orgRootRoot.roll = ROLL_NUMERATOR;
            newRootRoot.roll = ROLL_ROOT_ROOT;
            newRootRoot.parent = rBlock;

            frameX = orgRootRoot.mainFrame.origin.x;
            frameY = orgRootRoot.mainFrame.origin.y - gCurE.curFontH;
            frameW = orgRootRoot.mainFrame.size.width;
            frameH = orgRootRoot.mainFrame.size.height;

            newRootRoot.numerFrame = CGRectMake(frameX, frameY, frameW, frameH);
            newRootRoot.numerTopHalf = frameH / 2.0;
            newRootRoot.numerBtmHalf = frameH / 2.0;
            newRootRoot.denomFrame = CGRectMake(frameX, frameY + frameH, 0, gCurE.curFontH); //Make an empty denominator frame
            newRootRoot.denomTopHalf = gCurE.curFontH / 2.0;
            newRootRoot.denomBtmHalf = gCurE.curFontH / 2.0;
            newRootRoot.mainFrame = CGRectUnion(newRootRoot.numerFrame, newRootRoot.denomFrame);

            orgRootRoot.mainFrame = newRootRoot.numerFrame;
            orgRootRoot.c_idx = 0;
            orgRootRoot.parent = newRootRoot;
            [newRootRoot.children addObject: orgRootRoot];

            rBlock.content = newRootRoot;
            CGFloat orgW = rBlock.frame.size.width;
            [rBlock updateFrame];
            [rBlock setNeedsDisplay];
            if ([rBlock.parent isMemberOfClass:[EquationBlock class]]) {
                [(EquationBlock *)rBlock.parent updateFrameHeightS1:rBlock];
                [(EquationBlock *)rBlock.parent updateFrameWidth:rBlock.frame.size.width - orgW :rBlock.roll];
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            gCurE.curParent = newRootRoot;
            gCurE.curMode = MODE_INPUT;
        } else if(gCurE.curMode == MODE_DUMP_EXPO) {
            CGFloat frameW = 0.0;
            CGFloat frameH = 0.0;
            CGFloat frameX = 0.0;
            CGFloat frameY = 0.0;
            EquationTextLayer *l = gCurE.curParent;
            EquationBlock *orgExpo = l.expo;
            EquationBlock *newExpo = [[EquationBlock alloc] init:gCurE];
            orgExpo.roll = ROLL_NUMERATOR;
            newExpo.roll = ROLL_EXPO_ROOT;
            newExpo.parent = l;
            
            frameX = orgExpo.mainFrame.origin.x;
            frameY = orgExpo.mainFrame.origin.y - gCurE.curFontH;
            frameW = orgExpo.mainFrame.size.width;
            frameH = orgExpo.mainFrame.size.height;
            
            newExpo.numerFrame = CGRectMake(frameX, frameY, frameW, frameH);
            newExpo.numerTopHalf = frameH / 2.0;
            newExpo.numerBtmHalf = frameH / 2.0;
            newExpo.denomFrame = CGRectMake(frameX, frameY + frameH, 0, gCurE.curFontH); //Make an empty denominator frame
            newExpo.denomTopHalf = gCurE.curFontH / 2.0;
            newExpo.denomBtmHalf = gCurE.curFontH / 2.0;
            newExpo.mainFrame = CGRectUnion(newExpo.numerFrame, newExpo.denomFrame);
            
            orgExpo.mainFrame = newExpo.numerFrame;
            orgExpo.c_idx = 0;
            orgExpo.parent = newExpo;
            [newExpo.children addObject: orgExpo];
            
            l.expo = newExpo;
            [l updateFrameBaseOnExpo];
            if ([l.parent isMemberOfClass:[EquationBlock class]]) {
                [(EquationBlock *)l.parent updateFrameHeightS1:l];
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            
            gCurE.curParent = newExpo;
            gCurE.curMode = MODE_INPUT;
        } else if(gCurE.curMode == MODE_DUMP_WETL) {
            CGFloat frameW = 0.0;
            CGFloat frameH = 0.0;
            CGFloat frameX = 0.0;
            CGFloat frameY = 0.0;
            WrapedEqTxtLyr *wetl = gCurE.curParent;
            CGFloat orgW = wetl.mainFrame.size.width;
            EquationBlock *orgWrapRoot = wetl.content;
            EquationBlock *newWrapRoot = [[EquationBlock alloc] init:gCurE];
            orgWrapRoot.roll = ROLL_NUMERATOR;
            newWrapRoot.roll = ROLL_WRAP_ROOT;
            newWrapRoot.parent = wetl;
            
            frameX = orgWrapRoot.mainFrame.origin.x;
            frameY = orgWrapRoot.mainFrame.origin.y - gCurE.curFontH;
            frameW = orgWrapRoot.mainFrame.size.width;
            frameH = orgWrapRoot.mainFrame.size.height;
            
            newWrapRoot.numerFrame = CGRectMake(frameX, frameY, frameW, frameH);
            newWrapRoot.numerTopHalf = frameH / 2.0;
            newWrapRoot.numerBtmHalf = frameH / 2.0;
            newWrapRoot.denomFrame = CGRectMake(frameX, frameY + frameH, 0, gCurE.curFontH); //Make an empty denominator frame
            newWrapRoot.denomTopHalf = gCurE.curFontH / 2.0;
            newWrapRoot.denomBtmHalf = gCurE.curFontH / 2.0;
            newWrapRoot.mainFrame = CGRectUnion(newWrapRoot.numerFrame, newWrapRoot.denomFrame);
            
            orgWrapRoot.mainFrame = newWrapRoot.numerFrame;
            orgWrapRoot.c_idx = 0;
            orgWrapRoot.parent = newWrapRoot;
            [newWrapRoot.children addObject: orgWrapRoot];
            
            wetl.content = newWrapRoot;
            
            [wetl updateFrame:YES];
            
            if ([wetl.parent isMemberOfClass:[EquationBlock class]]) {
                [(EquationBlock *)wetl.parent updateFrameHeightS1:wetl];
                [(EquationBlock *)wetl.parent updateFrameWidth:wetl.mainFrame.size.width - orgW :wetl.roll];
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            gCurE.curParent = newWrapRoot;
            gCurE.curMode = MODE_INPUT;
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }

        gCurE.curRoll = ROLL_DENOMINATOR;
        
        EquationBlock *eBlock = gCurE.curParent;
        
        testeb = eBlock;
        
        /* Add a bar into eBlock */
        FractionBarLayer *barLayer = [[FractionBarLayer alloc] init:gCurE :self];
        barLayer.name = @"/";
        barLayer.hidden = NO;
        barLayer.backgroundColor = [UIColor clearColor].CGColor;
        barLayer.parent = eBlock;
        /*Make bar in the middle of numer and deno*/
        CGRect frame;
        frame.origin.x = eBlock.mainFrame.origin.x;
        frame.size.height = gCurE.curFontH / 2.0;
        frame.origin.y = eBlock.numerFrame.origin.y + eBlock.numerFrame.size.height - (frame.size.height / 2.0);
        frame.size.width = eBlock.mainFrame.size.width;
        
        barLayer.frame = frame;
        barLayer.c_idx = eBlock.children.count;
        [gCurE.view.layer addSublayer: barLayer];
        [barLayer setNeedsDisplay];
        [eBlock.children addObject: barLayer];
        eBlock.bar = barLayer;
        
        EquationTextLayer *layer = [[EquationTextLayer alloc] init:@"_" :eBlock.denomFrame.origin :gCurE :TEXTLAYER_EMPTY];
        layer.parent = eBlock;
        eBlock.denomFrame = layer.frame;
        layer.c_idx = eBlock.children.count;
        [eBlock.children addObject:layer];
        [gCurE.view.layer addSublayer: layer];
        
        gCurE.insertCIdx = layer.c_idx + 1;
        gCurE.txtInsIdx = 0;
        gCurE.curTxtLyr = layer;
        gCurE.curBlk = layer;
        [gCurE.root adjustElementPosition];
        
        /* Move cursor */
        CGFloat cursorOrgX = 0.0;
        CGFloat cursorOrgY = 0.0;
        cursorOrgX = eBlock.denomFrame.origin.x;
        cursorOrgY = eBlock.denomFrame.origin.y;
        gCurE.view.cursor.frame = CGRectMake(cursorOrgX, cursorOrgY, CURSOR_W, gCurE.curFontH);
        gCurE.view.inpOrg = CGPointMake(cursorOrgX, cursorOrgY);
        
        if (gCurE.root.mainFrame.origin.y < 0.0 && gCurE.zoomInLvl < 2) {
            gCurE.zoomInLvl++;
            [self zoom];
        }
    }
    
}

- (void)handleRootBtnClick: (int)rootCnt {
    CGFloat incrWidth = 0.0;
    
    if (gCurE.curTxtLyr != nil && gCurE.curTxtLyr.type == TEXTLAYER_EMPTY) {
        if (gCurE.curTxtLyr.expo == nil) {
            EquationBlock *cb = gCurE.curParent;
            [gCurE.curTxtLyr destroy];
            [cb.children removeObjectAtIndex:gCurE.curTxtLyr.c_idx];
            [cb updateCIdx];
            incrWidth -= gCurE.curTxtLyr.mainFrame.size.width;
        } else if ([gCurE.curTxtLyr.expo.children.firstObject isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *l = gCurE.curTxtLyr.expo.children.firstObject;
            if (l.type == TEXTLAYER_EMPTY) {
                EquationBlock *cb = gCurE.curParent;
                [gCurE.curTxtLyr destroy];
                [cb.children removeObjectAtIndex:gCurE.curTxtLyr.c_idx];
                [cb updateCIdx];
                incrWidth -= gCurE.curTxtLyr.mainFrame.size.width;
            } else {
                gCurE.curMode = MODE_INSERT;
                gCurE.insertCIdx = gCurE.curTxtLyr.c_idx;
            }
        } else {
            gCurE.curMode = MODE_INSERT;
            gCurE.insertCIdx = gCurE.curTxtLyr.c_idx;
        }
    }
    
    RadicalBlock *newRBlock = [[RadicalBlock alloc] init:gCurE.view.inpOrg :gCurE :rootCnt :self];
    
    incrWidth += newRBlock.frame.size.width;
    
//    if (orgLayer != nil && orgLayer.type == TEXTLAYER_EMPTY) {
//        EquationBlock *cb = gCurE.curBlk;
//        [orgLayer destroy];
//        [cb.children removeObjectAtIndex:orgLayer.c_idx];
//        [cb updateCIdx];
//        incrWidth -= orgLayer.mainFrame.size.width;
//    }
    
    
    if(gCurE.curMode == MODE_INPUT) {
        EquationBlock *eBlock = gCurE.curParent;
        
        newRBlock.c_idx = eBlock.children.count;
        
        [eBlock.children addObject:newRBlock];
    } else if(gCurE.curMode == MODE_INSERT) {
        EquationBlock *eBlock = gCurE.curParent;

        [eBlock.children insertObject:newRBlock atIndex: gCurE.insertCIdx];
        
        /*Update c_idx*/
        [eBlock updateCIdx];
    } else if(gCurE.curMode == MODE_DUMP_ROOT) {
        EquationBlock *newRoot = [[EquationBlock alloc] init:gCurE];
        newRoot.roll = ROLL_ROOT;
        newRoot.parent = nil;
        newRoot.numerFrame = gCurE.root.mainFrame;
        newRoot.numerTopHalf = gCurE.root.mainFrame.size.height / 2.0;
        newRoot.numerBtmHalf = gCurE.root.mainFrame.size.height / 2.0;
        newRoot.mainFrame = newRoot.numerFrame;
        gCurE.root.roll = ROLL_NUMERATOR;
        gCurE.root.parent = newRoot;
        if (gCurE.insertCIdx == 0) {
            gCurE.root.c_idx = 1;
            newRBlock.c_idx = 0;
            [newRoot.children addObject:newRBlock];
            [newRoot.children addObject:gCurE.root];
            gCurE.curMode = MODE_INSERT;
        } else {
            gCurE.root.c_idx = 0;
            [newRoot.children addObject:gCurE.root];
            newRBlock.c_idx = 1;
            [newRoot.children addObject:newRBlock];
            gCurE.curMode = MODE_INPUT;
        }
        gCurE.curParent = newRoot;
        gCurE.root = newRoot;
    } else if(gCurE.curMode == MODE_DUMP_RADICAL) {
        RadicalBlock *rBlock = gCurE.curParent;
        EquationBlock *orgRootRoot = rBlock.content;
        EquationBlock *newRootRoot = [[EquationBlock alloc] init:gCurE];
        newRootRoot.roll = ROLL_ROOT_ROOT;
        newRootRoot.parent = rBlock;
        newRootRoot.numerFrame = orgRootRoot.mainFrame;
        newRootRoot.numerTopHalf = orgRootRoot.mainFrame.size.height / 2.0;
        newRootRoot.numerBtmHalf = orgRootRoot.mainFrame.size.height / 2.0;
        newRootRoot.mainFrame = newRootRoot.numerFrame;
        orgRootRoot.roll = ROLL_NUMERATOR;
        orgRootRoot.parent = newRootRoot;
        
        if (gCurE.insertCIdx == 0) {
            orgRootRoot.c_idx = 1;
            newRBlock.c_idx = 0;
            [newRootRoot.children addObject:newRBlock];
            [newRootRoot.children addObject:orgRootRoot];
            gCurE.curMode = MODE_INSERT;
        } else {
            orgRootRoot.c_idx = 0;
            [newRootRoot.children addObject:orgRootRoot];
            newRBlock.c_idx = 1;
            [newRootRoot.children addObject:newRBlock];
            gCurE.curMode = MODE_INPUT;
        }
        
        rBlock.content = newRootRoot;
        gCurE.curParent = newRootRoot;
    } else if(gCurE.curMode == MODE_DUMP_EXPO) {
        EquationTextLayer *layer = gCurE.curParent;
        EquationBlock *orgExpo = layer.expo;
        EquationBlock *newExpo = [[EquationBlock alloc] init:gCurE];
        newExpo.roll = ROLL_EXPO_ROOT;
        newExpo.parent = layer;
        newExpo.numerFrame = orgExpo.mainFrame;
        newExpo.numerTopHalf = orgExpo.mainFrame.size.height / 2.0;
        newExpo.numerBtmHalf = orgExpo.mainFrame.size.height / 2.0;
        newExpo.mainFrame = newExpo.numerFrame;
        orgExpo.roll = ROLL_NUMERATOR;
        orgExpo.parent = newExpo;
        
        if (gCurE.insertCIdx == 0) {
            newRBlock.c_idx = 0;
            [newExpo.children addObject:newRBlock];
            orgExpo.c_idx = 1;
            [newExpo.children addObject:orgExpo];
            gCurE.curMode = MODE_INSERT;
        } else {
            orgExpo.c_idx = 0;
            [newExpo.children addObject:orgExpo];
            newRBlock.c_idx = 1;
            [newExpo.children addObject:newRBlock];
            gCurE.curMode = MODE_INPUT;
        }
        
        layer.expo = newExpo;
        gCurE.curParent = newExpo;
    } else if(gCurE.curMode == MODE_DUMP_WETL) {
        WrapedEqTxtLyr *wetl = gCurE.curParent;
        EquationBlock *orgWrapRoot = wetl.content;
        EquationBlock *newWrapRoot = [[EquationBlock alloc] init:gCurE];
        newWrapRoot.roll = ROLL_ROOT_ROOT;
        newWrapRoot.parent = wetl;
        newWrapRoot.numerFrame = orgWrapRoot.mainFrame;
        newWrapRoot.numerTopHalf = orgWrapRoot.mainFrame.size.height / 2.0;
        newWrapRoot.numerBtmHalf = orgWrapRoot.mainFrame.size.height / 2.0;
        newWrapRoot.mainFrame = newWrapRoot.numerFrame;
        orgWrapRoot.roll = ROLL_NUMERATOR;
        orgWrapRoot.parent = newWrapRoot;
        
        if (gCurE.insertCIdx == 0) {
            orgWrapRoot.c_idx = 1;
            newRBlock.c_idx = 0;
            [newWrapRoot.children addObject:newRBlock];
            [newWrapRoot.children addObject:orgWrapRoot];
            gCurE.curMode = MODE_INSERT;
        } else {
            orgWrapRoot.c_idx = 0;
            [newWrapRoot.children addObject:orgWrapRoot];
            newRBlock.c_idx = 1;
            [newWrapRoot.children addObject:newRBlock];
            gCurE.curMode = MODE_INPUT;
        }
        
        wetl.content = newWrapRoot;
        gCurE.curParent = newWrapRoot;
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    
    newRBlock.parent = gCurE.curParent;

    [gCurE.view.layer addSublayer: newRBlock];
    [newRBlock setNeedsDisplay];
    
    [(EquationBlock *)gCurE.curParent updateFrameWidth:incrWidth :gCurE.curRoll];
    [(EquationBlock *)gCurE.curParent updateFrameHeightS1:newRBlock];
    [gCurE.root adjustElementPosition];
    
    gCurE.insertCIdx = 1;
    gCurE.txtInsIdx = 0;
    gCurE.curMode = MODE_INPUT;
    gCurE.curRoll = ROLL_NUMERATOR;
    gCurE.curParent = newRBlock.content;
    gCurE.view.inpOrg = ((EquationBlock *)gCurE.curParent).mainFrame.origin;
    gCurE.view.cursor.frame = CGRectMake(gCurE.view.inpOrg.x, gCurE.view.inpOrg.y, CURSOR_W, gCurE.curFontH);
    
    if ((gCurE.root.mainFrame.origin.y < 0.0 || gCurE.root.mainFrame.origin.x + gCurE.root.mainFrame.size.width > scnWidth) && gCurE.zoomInLvl < 2) {
        gCurE.zoomInLvl++;
        [self zoom];
    }
}

- (void)handlePowBtnClick {
    if (gCurE.curFont == gCurE.superscriptFont || gCurE.curMode == MODE_DUMP_EXPO) { // TODO
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        return;
    }
    
    if (gCurE.curTxtLyr == nil) {
        CGPoint pos = gCurE.view.inpOrg;
        CGFloat incrWidth = 0.0;
        
        EquationTextLayer *baseLayer = [[EquationTextLayer alloc] init:@"_" :pos :gCurE :TEXTLAYER_EMPTY];
        //baseLayer.parent = gCurE.curParent;
        [gCurE.view.layer addSublayer: baseLayer];
        
        pos.x += baseLayer.frame.size.width;
        pos.y = (pos.y + gCurE.baseCharHight * 0.45) - gCurE.expoCharHight;
        
        gCurE.curFont = gCurE.superscriptFont;
        
        EquationBlock *exp = [[EquationBlock alloc] init:pos :gCurE];
        exp.roll = ROLL_EXPO_ROOT;
        exp.parent = baseLayer;
        baseLayer.expo = exp;
        
        EquationTextLayer *expLayer = [[EquationTextLayer alloc] init:@"_" :pos :gCurE :TEXTLAYER_EMPTY];
        expLayer.parent = exp;
        exp.numerFrame = expLayer.frame;
        exp.mainFrame = expLayer.frame;
        expLayer.roll = ROLL_NUMERATOR;
        expLayer.c_idx = 0;
        [exp.children addObject:expLayer];
        [gCurE.view.layer addSublayer: expLayer];
        [baseLayer updateFrameBaseOnExpo];
        
        incrWidth = baseLayer.mainFrame.size.width;
        
        gCurE.curFont = gCurE.baseFont;
        
        if(gCurE.curMode == MODE_INPUT) {
            EquationBlock *eb = gCurE.curParent;

            baseLayer.c_idx = eb.children.count;
            [eb.children addObject:baseLayer];
        } else if(gCurE.curMode == MODE_INSERT) {
            EquationBlock *eb = gCurE.curParent;

            [eb.children insertObject:baseLayer atIndex: gCurE.insertCIdx];

            /*Update c_idx*/
            [eb updateCIdx];
        } else if(gCurE.curMode == MODE_DUMP_ROOT) {
            EquationBlock *newRoot = [[EquationBlock alloc] init:gCurE];
            newRoot.roll = ROLL_ROOT;
            newRoot.parent = nil;
            newRoot.numerFrame = gCurE.root.mainFrame;
            newRoot.numerTopHalf = gCurE.root.mainFrame.size.height / 2.0;
            newRoot.numerBtmHalf = gCurE.root.mainFrame.size.height / 2.0;
            newRoot.mainFrame = newRoot.numerFrame;
            gCurE.root.roll = ROLL_NUMERATOR;
            gCurE.root.parent = newRoot;
            
            if (gCurE.insertCIdx == 0) {
                baseLayer.c_idx = 0;
                [newRoot.children addObject:baseLayer];
                gCurE.root.c_idx = 1;
                [newRoot.children addObject:gCurE.root];
                gCurE.curMode = MODE_INSERT;
            } else {
                gCurE.root.c_idx = 0;
                [newRoot.children addObject:gCurE.root];
                baseLayer.c_idx = 1;
                [newRoot.children addObject:baseLayer];
                gCurE.curMode = MODE_INPUT;
            }
            
            gCurE.root = newRoot;
            gCurE.curParent = newRoot;
        } else if(gCurE.curMode == MODE_DUMP_RADICAL) {
            RadicalBlock *rBlock = gCurE.curParent;
            EquationBlock *orgRootRoot = rBlock.content;
            EquationBlock *newRootRoot = [[EquationBlock alloc] init:gCurE];
            newRootRoot.roll = ROLL_ROOT_ROOT;
            newRootRoot.parent = rBlock;
            newRootRoot.numerFrame = orgRootRoot.mainFrame;
            newRootRoot.numerTopHalf = orgRootRoot.mainFrame.size.height / 2.0;
            newRootRoot.numerBtmHalf = orgRootRoot.mainFrame.size.height / 2.0;
            newRootRoot.mainFrame = newRootRoot.numerFrame;
            orgRootRoot.roll = ROLL_NUMERATOR;
            orgRootRoot.parent = newRootRoot;
            
            if (gCurE.insertCIdx == 0) {
                baseLayer.c_idx = 0;
                [newRootRoot.children addObject:baseLayer];
                orgRootRoot.c_idx = 1;
                [newRootRoot.children addObject:orgRootRoot];
                gCurE.curMode = MODE_INSERT;
            } else {
                orgRootRoot.c_idx = 0;
                [newRootRoot.children addObject:orgRootRoot];
                baseLayer.c_idx = 1;
                [newRootRoot.children addObject:baseLayer];
                gCurE.curMode = MODE_INPUT;
            }
            
            rBlock.content = newRootRoot;
            gCurE.curParent = newRootRoot;
        } else if(gCurE.curMode == MODE_DUMP_WETL) {
            WrapedEqTxtLyr *wetl = gCurE.curParent;
            EquationBlock *orgWrapRoot = wetl.content;
            EquationBlock *newWrapRoot = [[EquationBlock alloc] init:gCurE];
            newWrapRoot.roll = ROLL_WRAP_ROOT;
            newWrapRoot.parent = wetl;
            newWrapRoot.numerFrame = orgWrapRoot.mainFrame;
            newWrapRoot.numerTopHalf = orgWrapRoot.mainFrame.size.height / 2.0;
            newWrapRoot.numerBtmHalf = orgWrapRoot.mainFrame.size.height / 2.0;
            newWrapRoot.mainFrame = newWrapRoot.numerFrame;
            orgWrapRoot.roll = ROLL_NUMERATOR;
            orgWrapRoot.parent = newWrapRoot;
            
            if (gCurE.insertCIdx == 0) {
                baseLayer.c_idx = 0;
                [newWrapRoot.children addObject:baseLayer];
                orgWrapRoot.c_idx = 1;
                [newWrapRoot.children addObject:orgWrapRoot];
                gCurE.curMode = MODE_INSERT;
            } else {
                orgWrapRoot.c_idx = 0;
                [newWrapRoot.children addObject:orgWrapRoot];
                baseLayer.c_idx = 1;
                [newWrapRoot.children addObject:baseLayer];
                gCurE.curMode = MODE_INPUT;
            }
            
            wetl.content = newWrapRoot;
            gCurE.curParent = newWrapRoot;
        } else
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        
        baseLayer.parent = gCurE.curParent;
        
        [(EquationBlock *)gCurE.curParent updateFrameWidth:incrWidth :gCurE.curRoll];
        [(EquationBlock *)gCurE.curParent updateFrameHeightS1:baseLayer];
        [gCurE.root adjustElementPosition];
        
        gCurE.insertCIdx = baseLayer.c_idx + 1;
        gCurE.txtInsIdx = 0;
        gCurE.curTxtLyr = baseLayer;
        gCurE.curBlk = baseLayer;
        gCurE.view.inpOrg = baseLayer.frame.origin;
        gCurE.view.cursor.frame = CGRectMake(gCurE.view.inpOrg.x, gCurE.view.inpOrg.y, CURSOR_W, gCurE.curFontH);
        
        if ((gCurE.root.mainFrame.origin.y < 0.0 || gCurE.root.mainFrame.origin.x + gCurE.root.mainFrame.size.width > scnWidth) && gCurE.zoomInLvl < 2) {
            gCurE.zoomInLvl++;
            [self zoom];
        }
    } else {
        gCurE.curFont = gCurE.superscriptFont;
        
        if (gCurE.curTxtLyr.expo == nil) {
            CGFloat orgW = gCurE.curTxtLyr.mainFrame.size.width;
            CGFloat x = gCurE.curTxtLyr.frame.origin.x + orgW;
            
            CGFloat y = (gCurE.view.inpOrg.y + gCurE.baseCharHight * 0.45) - gCurE.expoCharHight;
            gCurE.view.inpOrg = CGPointMake(x, y);
            gCurE.view.cursor.frame = CGRectMake(gCurE.view.inpOrg.x, gCurE.view.inpOrg.y, CURSOR_W, gCurE.expoCharHight);
            
            EquationBlock *eBlock = [[EquationBlock alloc] init:gCurE.view.inpOrg :gCurE];
            eBlock.roll = ROLL_EXPO_ROOT;
            eBlock.parent = gCurE.curTxtLyr;
            gCurE.curTxtLyr.expo = eBlock;
            
            EquationTextLayer *layer = [[EquationTextLayer alloc] init:@"_" :gCurE.view.inpOrg :gCurE :TEXTLAYER_EMPTY];
            layer.parent = eBlock;
            eBlock.numerFrame = layer.frame;
            eBlock.mainFrame = layer.frame;
            layer.roll = ROLL_NUMERATOR;
            layer.c_idx = 0;
            [eBlock.children addObject:layer];
            [gCurE.view.layer addSublayer: layer];
            [gCurE.curTxtLyr updateFrameBaseOnExpo];
            
            CGFloat inc = gCurE.curTxtLyr.mainFrame.size.width - orgW;
            [(EquationBlock *)gCurE.curParent updateFrameWidth:inc :gCurE.curRoll];
            [(EquationBlock *)gCurE.curParent updateFrameHeightS1:gCurE.curTxtLyr];
            [gCurE.root adjustElementPosition];
            
            gCurE.insertCIdx = layer.c_idx + 1;
            gCurE.txtInsIdx = 0;
            gCurE.curTxtLyr = layer;
            gCurE.curBlk = layer;
            gCurE.curParent = eBlock;
            gCurE.curRoll = ROLL_NUMERATOR;
            gCurE.curMode = MODE_INPUT;
            
            if ((gCurE.root.mainFrame.origin.y < 0.0 || gCurE.root.mainFrame.origin.x + gCurE.root.mainFrame.size.width > scnWidth) && gCurE.zoomInLvl < 2) {
                gCurE.zoomInLvl++;
                [self zoom];
            }
        } else {
            EquationBlock *exp = gCurE.curTxtLyr.expo;
            id lastObj = exp.children.lastObject;

            locaLastTxtLyr(gCurE, lastObj);
        }
        
    }
}

- (void)handleParenthBtnClick : (int)l_r {
    CGFloat incrWidth = 0.0;
    
    if (gCurE.curTxtLyr != nil && gCurE.curTxtLyr.type == TEXTLAYER_EMPTY) {
        if (gCurE.curTxtLyr.expo == nil) {
            EquationBlock *cb = gCurE.curParent;
            [gCurE.curTxtLyr destroy];
            [cb.children removeObjectAtIndex:gCurE.curTxtLyr.c_idx];
            [cb updateCIdx];
            incrWidth -= gCurE.curTxtLyr.mainFrame.size.width;
        } else if ([gCurE.curTxtLyr.expo.children.firstObject isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *l = gCurE.curTxtLyr.expo.children.firstObject;
            if (l.type == TEXTLAYER_EMPTY) {
                EquationBlock *cb = gCurE.curParent;
                [gCurE.curTxtLyr destroy];
                [cb.children removeObjectAtIndex:gCurE.curTxtLyr.c_idx];
                [cb updateCIdx];
                incrWidth -= gCurE.curTxtLyr.mainFrame.size.width;
            } else {
                gCurE.curMode = MODE_INSERT;
                gCurE.insertCIdx = gCurE.curTxtLyr.c_idx;
            }
        } else {
            gCurE.curMode = MODE_INSERT;
            gCurE.insertCIdx = gCurE.curTxtLyr.c_idx;
        }
    }

    Parentheses *parenth = [[Parentheses alloc] init:gCurE.view.inpOrg :gCurE :l_r :self];
    
    if(gCurE.curMode == MODE_INPUT) {
        EquationBlock *block = gCurE.curParent;
        
        parenth.c_idx = block.children.count;
        [block.children addObject:parenth];
    } else if(gCurE.curMode == MODE_INSERT) {
        EquationBlock *block = gCurE.curParent;
        
        parenth.c_idx = gCurE.insertCIdx;
        [block.children insertObject:parenth atIndex:parenth.c_idx];
        /*Update c_idx*/
        [block updateCIdx];
    } else if(gCurE.curMode == MODE_DUMP_ROOT) {
        EquationBlock *newRoot = [[EquationBlock alloc] init:gCurE];
        newRoot.roll = ROLL_ROOT;
        newRoot.parent = nil;
        newRoot.numerFrame = gCurE.root.mainFrame;
        newRoot.numerTopHalf = gCurE.root.mainFrame.size.height / 2.0;
        newRoot.numerBtmHalf = gCurE.root.mainFrame.size.height / 2.0;
        newRoot.mainFrame = newRoot.numerFrame;
        gCurE.root.roll = ROLL_NUMERATOR;
        gCurE.root.parent = newRoot;
        
        if (gCurE.insertCIdx == 0) {
            parenth.c_idx = 0;
            [newRoot.children addObject:parenth];
            gCurE.root.c_idx = 1;
            [newRoot.children addObject:gCurE.root];
            gCurE.curMode = MODE_INSERT;
        } else {
            gCurE.root.c_idx = 0;
            [newRoot.children addObject:gCurE.root];
            parenth.c_idx = 1;
            [newRoot.children addObject:parenth];
            gCurE.curMode = MODE_INPUT;
        }
        
        gCurE.root = newRoot;
        gCurE.curParent = newRoot;
    } else if(gCurE.curMode == MODE_DUMP_RADICAL) {
        RadicalBlock *rBlock = gCurE.curParent;
        EquationBlock *orgRootRoot = rBlock.content;
        EquationBlock *newRootRoot = [[EquationBlock alloc] init:gCurE];
        newRootRoot.roll = ROLL_ROOT_ROOT;
        newRootRoot.parent = rBlock;
        newRootRoot.numerFrame = orgRootRoot.mainFrame;
        newRootRoot.numerTopHalf = orgRootRoot.mainFrame.size.height / 2.0;
        newRootRoot.numerBtmHalf = orgRootRoot.mainFrame.size.height / 2.0;
        newRootRoot.mainFrame = newRootRoot.numerFrame;
        orgRootRoot.roll = ROLL_NUMERATOR;
        orgRootRoot.parent = newRootRoot;
        
        if (gCurE.insertCIdx == 0) {
            parenth.c_idx = 0;
            [newRootRoot.children addObject:parenth];
            orgRootRoot.c_idx = 1;
            [newRootRoot.children addObject:orgRootRoot];
            gCurE.curMode = MODE_INSERT;
            gCurE.insertCIdx = 1;
        } else {
            orgRootRoot.c_idx = 0;
            [newRootRoot.children addObject:orgRootRoot];
            parenth.c_idx = 1;
            [newRootRoot.children addObject:parenth];
            gCurE.curMode = MODE_INPUT;
        }
        
        rBlock.content = newRootRoot;
        gCurE.curParent = newRootRoot;
    } else if(gCurE.curMode == MODE_DUMP_EXPO) {
        EquationTextLayer *layer = gCurE.curParent;
        EquationBlock *orgExpo = layer.expo;
        EquationBlock *newExpo = [[EquationBlock alloc] init:gCurE];
        newExpo.roll = ROLL_EXPO_ROOT;
        newExpo.parent = layer;
        newExpo.numerFrame = orgExpo.mainFrame;
        newExpo.numerTopHalf = orgExpo.mainFrame.size.height / 2.0;
        newExpo.numerBtmHalf = orgExpo.mainFrame.size.height / 2.0;
        newExpo.mainFrame = newExpo.numerFrame;
        orgExpo.roll = ROLL_NUMERATOR;
        orgExpo.parent = newExpo;
        
        if (gCurE.insertCIdx == 0) {
            orgExpo.c_idx = 1;
            parenth.c_idx = 0;
            [newExpo.children addObject:parenth];
            [newExpo.children addObject:orgExpo];
            gCurE.curMode = MODE_INSERT;
            gCurE.insertCIdx = 1;
        } else {
            orgExpo.c_idx = 0;
            [newExpo.children addObject:orgExpo];
            parenth.c_idx = 1;
            [newExpo.children addObject:parenth];
            gCurE.curMode = MODE_INPUT;
        }
        
        layer.expo = newExpo;
        gCurE.curParent = newExpo;
    } else if(gCurE.curMode == MODE_DUMP_WETL) {
        WrapedEqTxtLyr *wetl = gCurE.curParent;
        EquationBlock *orgWrapRoot = wetl.content;
        EquationBlock *newWrapRoot = [[EquationBlock alloc] init:gCurE];
        newWrapRoot.roll = ROLL_ROOT_ROOT;
        newWrapRoot.parent = wetl;
        newWrapRoot.numerFrame = orgWrapRoot.mainFrame;
        newWrapRoot.numerTopHalf = orgWrapRoot.mainFrame.size.height / 2.0;
        newWrapRoot.numerBtmHalf = orgWrapRoot.mainFrame.size.height / 2.0;
        newWrapRoot.mainFrame = newWrapRoot.numerFrame;
        orgWrapRoot.roll = ROLL_NUMERATOR;
        orgWrapRoot.parent = newWrapRoot;
        
        if (gCurE.insertCIdx == 0) {
            parenth.c_idx = 0;
            [newWrapRoot.children addObject:parenth];
            orgWrapRoot.c_idx = 1;
            [newWrapRoot.children addObject:orgWrapRoot];
            gCurE.curMode = MODE_INSERT;
            gCurE.insertCIdx = 1;
        } else {
            orgWrapRoot.c_idx = 0;
            [newWrapRoot.children addObject:orgWrapRoot];
            parenth.c_idx = 1;
            [newWrapRoot.children addObject:parenth];
            gCurE.curMode = MODE_INPUT;
        }
        
        wetl.content = newWrapRoot;
        gCurE.curParent = newWrapRoot;
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        return;
    }
    
    parenth.parent = gCurE.curParent;
    
    if(l_r == LEFT_PARENTH) {
        EquationBlock *par = parenth.parent;
        CGFloat h = gCurE.curFontH;
        int pcnt = 1;
        for (int i = parenth.c_idx + 1; i < par.children.count; i++) {
            id b = [par.children objectAtIndex:i];
            if([b isMemberOfClass:[EquationBlock class]]) {
                EquationBlock * eb = b;
                if (h < eb.mainFrame.size.height)
                    h = eb.mainFrame.size.height;
            } else if([b isMemberOfClass:[RadicalBlock class]]) {
                RadicalBlock * rb = b;
                if (h < rb.frame.size.height)
                    h = rb.frame.size.height;
            } else if([b isMemberOfClass:[EquationTextLayer class]]) {
                EquationTextLayer *layer = b;
                if (h < layer.mainFrame.size.height)
                    h = layer.mainFrame.size.height;
            } else if([b isMemberOfClass:[FractionBarLayer class]]) {
                break;
            } else if([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                WrapedEqTxtLyr *wetl = b;
                if (h < wetl.mainFrame.size.height)
                    h = wetl.mainFrame.size.height;
            } else if([b isMemberOfClass:[Parentheses class]]) {
                Parentheses *p = b;
                if (p.l_or_r == RIGHT_PARENTH) {
                    pcnt--;
                    
                    if (pcnt == 0) {
                        parenth.frame = CGRectMake(parenth.frame.origin.x, parenth.frame.origin.y, h / PARENTH_HW_R, h);
                        CGFloat orgW = p.frame.size.width;
                        p.frame = CGRectMake(p.frame.origin.x, p.frame.origin.y, h / PARENTH_HW_R, h);
                        [p setNeedsDisplay]; // TODO: Optimize
                        incrWidth += (p.frame.size.width - orgW);
                        break;
                    }
                } else
                    pcnt++;
                
                if (h < p.frame.size.height)
                    h = p.frame.size.height;
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
        }
    } else {
        EquationBlock *par = parenth.parent;
        CGFloat h = gCurE.curFontH;
        int pcnt = 1;
        for (int i = parenth.c_idx - 1; i >= 0; i--) {
            id b = [par.children objectAtIndex:i];
            if([b isMemberOfClass:[EquationBlock class]]) {
                EquationBlock * eb = b;
                if (h < eb.mainFrame.size.height)
                    h = eb.mainFrame.size.height;
            } else if([b isMemberOfClass:[RadicalBlock class]]) {
                RadicalBlock * rb = b;
                if (h < rb.frame.size.height)
                    h = rb.frame.size.height;
            } else if([b isMemberOfClass:[EquationTextLayer class]]) {
                EquationTextLayer *layer = b;
                if (h < layer.mainFrame.size.height)
                    h = layer.mainFrame.size.height;
            } else if([b isMemberOfClass:[FractionBarLayer class]]) {
                break;
            } else if([b isMemberOfClass:[WrapedEqTxtLyr class]]) {
                WrapedEqTxtLyr *wetl = b;
                if (h < wetl.mainFrame.size.height)
                    h = wetl.mainFrame.size.height;
            } else if([b isMemberOfClass:[Parentheses class]]) {
                Parentheses *p = b;
                if (p.l_or_r == LEFT_PARENTH) {
                    pcnt--;
                    
                    if (pcnt == 0) {
                        parenth.frame = CGRectMake(parenth.frame.origin.x, parenth.frame.origin.y, h / PARENTH_HW_R, h);
                        CGFloat orgW = p.frame.size.width;
                        p.frame = CGRectMake(p.frame.origin.x, p.frame.origin.y, h / PARENTH_HW_R, h);
                        [p setNeedsDisplay]; // TODO: Optimize
                        incrWidth += (p.frame.size.width - orgW);
                        break;
                    }
                } else
                    pcnt++;
                
                if (h < p.frame.size.height)
                    h = p.frame.size.height;
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
        }
    }
    
    [gCurE.view.layer addSublayer:parenth];
    [parenth setNeedsDisplay];
    
    incrWidth += parenth.frame.size.width;
    
    /* Update frame info of current block */
    [(EquationBlock *)gCurE.curParent updateFrameWidth:incrWidth :gCurE.curRoll];
    [gCurE.root adjustElementPosition];
    
    /* Move cursor */
    CGFloat cursorOrgX = parenth.frame.origin.x + parenth.frame.size.width;
    CGFloat cursorOrgY = parenth.frame.origin.y;
    
    gCurE.view.cursor.frame = CGRectMake(cursorOrgX, cursorOrgY, CURSOR_W, parenth.frame.size.height);
    gCurE.view.inpOrg = CGPointMake(cursorOrgX, cursorOrgY + parenth.frame.size.height / 2.0 - gCurE.curFontH / 2.0);
    
    gCurE.insertCIdx = parenth.c_idx + 1;
    gCurE.curBlk = parenth;
    gCurE.curTxtLyr = nil;
    
    if (gCurE.root.mainFrame.origin.x + gCurE.root.mainFrame.size.width > scnWidth && gCurE.zoomInLvl < 2) {
        gCurE.zoomInLvl++;
        [self zoom];
    }
}

- (void)handleDelBtnClick {
    if ([gCurE.curBlk isMemberOfClass:[EquationBlock class]]) {
        EquationBlock *eb = gCurE.curBlk;
        if (gCurE.insertCIdx == eb.c_idx) {
            id pre = getPrevBlk(gCurE, eb);
            if (pre == nil) {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
            
            EquationBlock *par = eb.parent;
            if (eb.c_idx == 0 || [[par.children objectAtIndex:eb.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *layer = pre;
                    if (layer.is_base_expo == eb.is_base_expo) {
                        (void)locaLastTxtLyr(gCurE, pre);
                    } else { //Switch from expo to base in a same text layer
                        cfgEqnBySlctBlk(gCurE, layer, CGPointMake(layer.frame.origin.x + layer.frame.size.width - 1.0, layer.frame.origin.y + 1.0));
                    }
                } else if ([pre isMemberOfClass:[Parentheses class]]) {
                    Parentheses *p = pre;
                    cfgEqnBySlctBlk(gCurE, p, CGPointMake(p.frame.origin.x + p.frame.size.width - 1.0, p.frame.origin.y + 1.0));
                } else {
                    (void)locaLastTxtLyr(gCurE, pre);
                }
            } else {
                if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *l = pre;
                    if (l.expo != nil) {
                        (void)locaLastTxtLyr(gCurE, l);
                    } else {
                        if (l.strLenTbl.count == 2 || l.strLenTbl.count == 1) { // 1 char num/op/empty
                            [gCurE removeElement:l];
                        } else {
                            CGFloat orgW = l.mainFrame.size.width;
                            [l delNumCharAt:(int)l.strLenTbl.count - 1];
                            CGFloat incrWidth = l.mainFrame.size.width - orgW;
                            [(EquationBlock *)l.parent updateFrameWidth:incrWidth :l.roll];
                            [gCurE.root adjustElementPosition];
                            cfgEqnBySlctBlk(gCurE, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                        }
                    }
                } else if ([pre isMemberOfClass:[Parentheses class]]) {
                    [gCurE removeElement:pre];
                } else {
                    (void)locaLastTxtLyr(gCurE, pre);
                }
            }
        } else if (gCurE.insertCIdx == eb.c_idx + 1) {
            (void)locaLastTxtLyr(gCurE, eb);
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return;
        }
    } else if ([gCurE.curBlk isMemberOfClass:[RadicalBlock class]]) {
        RadicalBlock *rb = gCurE.curBlk;
        if (gCurE.insertCIdx == rb.c_idx) {
            id pre = getPrevBlk(gCurE, rb);
            if (pre == nil) {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
            
            EquationBlock *par = rb.parent;
            if (rb.c_idx == 0 || [[par.children objectAtIndex:rb.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *layer = pre;
                    if (layer.is_base_expo == rb.is_base_expo) {
                        (void)locaLastTxtLyr(gCurE, pre);
                    } else { //Switch from expo to base in a same text layer
                        cfgEqnBySlctBlk(gCurE, layer, CGPointMake(layer.frame.origin.x + layer.frame.size.width - 1.0, layer.frame.origin.y + 1.0));
                    }
                } else if ([pre isMemberOfClass:[Parentheses class]]) {
                    Parentheses *p = pre;
                    cfgEqnBySlctBlk(gCurE, p, CGPointMake(p.frame.origin.x + p.frame.size.width - 1.0, p.frame.origin.y + 1.0));
                } else {
                    (void)locaLastTxtLyr(gCurE, pre);
                }
            } else {
                if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *l = pre;
                    if (l.expo != nil) {
                        (void)locaLastTxtLyr(gCurE, l);
                    } else {
                        if (l.strLenTbl.count == 2 || l.strLenTbl.count == 1) { // 1 char num/op/empty
                            [gCurE removeElement:l];
                        } else {
                            CGFloat orgW = l.mainFrame.size.width;
                            [l delNumCharAt:(int)l.strLenTbl.count - 1];
                            CGFloat incrWidth = l.mainFrame.size.width - orgW;
                            [(EquationBlock *)l.parent updateFrameWidth:incrWidth :l.roll];
                            [gCurE.root adjustElementPosition];
                            cfgEqnBySlctBlk(gCurE, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                        }
                    }
                } else if ([pre isMemberOfClass:[Parentheses class]]) {
                    [gCurE removeElement:pre];
                } else {
                    (void)locaLastTxtLyr(gCurE, pre);
                }
            }
        } else if (gCurE.insertCIdx == rb.c_idx + 1) {
            (void)locaLastTxtLyr(gCurE, rb);
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return;
        }
    } else if ([gCurE.curBlk isMemberOfClass:[WrapedEqTxtLyr class]]) {
        WrapedEqTxtLyr *wetl = gCurE.curBlk;
        if (gCurE.insertCIdx == wetl.c_idx) {
            id pre = getPrevBlk(gCurE, wetl);
            if (pre == nil) {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
            
            EquationBlock *par = wetl.parent;
            if (wetl.c_idx == 0 || [[par.children objectAtIndex:wetl.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *layer = pre;
                    if (layer.is_base_expo == wetl.is_base_expo) {
                        (void)locaLastTxtLyr(gCurE, pre);
                    } else { //Switch from expo to base in a same text layer
                        cfgEqnBySlctBlk(gCurE, layer, CGPointMake(layer.frame.origin.x + layer.frame.size.width - 1.0, layer.frame.origin.y + 1.0));
                    }
                } else if ([pre isMemberOfClass:[Parentheses class]]) {
                    Parentheses *p = pre;
                    cfgEqnBySlctBlk(gCurE, p, CGPointMake(p.frame.origin.x + p.frame.size.width - 1.0, p.frame.origin.y + 1.0));
                } else {
                    (void)locaLastTxtLyr(gCurE, pre);
                }
            } else {
                if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *l = pre;
                    if (l.expo != nil) {
                        (void)locaLastTxtLyr(gCurE, l);
                    } else {
                        if (l.strLenTbl.count == 2 || l.strLenTbl.count == 1) { // 1 char num/op/empty
                            [gCurE removeElement:l];
                        } else {
                            CGFloat orgW = l.mainFrame.size.width;
                            [l delNumCharAt:(int)l.strLenTbl.count - 1];
                            CGFloat incrWidth = l.mainFrame.size.width - orgW;
                            [(EquationBlock *)l.parent updateFrameWidth:incrWidth :l.roll];
                            [gCurE.root adjustElementPosition];
                            cfgEqnBySlctBlk(gCurE, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                        }
                    }
                } else if ([pre isMemberOfClass:[Parentheses class]]) {
                    [gCurE removeElement:pre];
                } else {
                    (void)locaLastTxtLyr(gCurE, pre);
                }
            }
        } else if (gCurE.insertCIdx == wetl.c_idx + 1) {
            (void)locaLastTxtLyr(gCurE, wetl);
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return;
        }
    } else if ([gCurE.curBlk isMemberOfClass:[FractionBarLayer class]]) {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        return;
    } else if ([gCurE.curBlk isMemberOfClass:[EquationTextLayer class]]) {
        EquationTextLayer *curLayer = gCurE.curBlk;
        EquationBlock *par = curLayer.parent;
        if (gCurE.insertCIdx == curLayer.c_idx) {
            id pre = getPrevBlk(gCurE, curLayer);
            if (pre == nil) {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
            
            if (curLayer.c_idx == 0 || [[par.children objectAtIndex:curLayer.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *layer = pre;
                    if (layer.is_base_expo == curLayer.is_base_expo) {
                        (void)locaLastTxtLyr(gCurE, pre);
                    } else { //Switch from expo to base in a same text layer
                        cfgEqnBySlctBlk(gCurE, layer, CGPointMake(layer.frame.origin.x + layer.frame.size.width - 1.0, layer.frame.origin.y + 1.0));
                    }
                } else if ([pre isMemberOfClass:[Parentheses class]]) {
                    Parentheses *p = pre;
                    cfgEqnBySlctBlk(gCurE, p, CGPointMake(p.frame.origin.x + p.frame.size.width - 1.0, p.frame.origin.y + 1.0));
                } else {
                    (void)locaLastTxtLyr(gCurE, pre);
                }
            } else {
                if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *l = pre;
                    if (l.expo != nil) {
                        (void)locaLastTxtLyr(gCurE, l);
                    } else {
                        if (l.strLenTbl.count == 2 || l.strLenTbl.count == 1) { // 1 char num/op/empty
                            [gCurE removeElement:l];
                        } else {
                            CGFloat orgW = l.mainFrame.size.width;
                            [l delNumCharAt:(int)l.strLenTbl.count - 1];
                            CGFloat incrWidth = l.mainFrame.size.width - orgW;
                            [(EquationBlock *)l.parent updateFrameWidth:incrWidth :l.roll];
                            [gCurE.root adjustElementPosition];
                            cfgEqnBySlctBlk(gCurE, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                        }
                    }
                } else if ([pre isMemberOfClass:[Parentheses class]]) {
                    [gCurE removeElement:pre];
                } else {
                    (void)locaLastTxtLyr(gCurE, pre);
                }
            }
        } else if (gCurE.insertCIdx == curLayer.c_idx + 1) {
            if (curLayer.expo != nil && gCurE.curTxtLyr == nil) {
                id blk = curLayer.expo.children.lastObject;
                (void)locaLastTxtLyr(gCurE, blk);
            } else if (curLayer.expo != nil && gCurE.curTxtLyr != nil) {
                if (curLayer.strLenTbl.count == 2 && gCurE.txtInsIdx == 1) { // Number 1 char
                    NSMutableAttributedString *orgStr = [[NSMutableAttributedString alloc] initWithAttributedString:curLayer.string];
                    CGFloat orgWidth = [orgStr size].width;
                    [orgStr replaceCharactersInRange:NSMakeRange(0, 1) withString:@"_"];
                    [orgStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0,1)];
                    CGFloat newWidth = [orgStr size].width;
                    CGFloat incrWidth = newWidth - orgWidth;
                    
                    CGRect frame = curLayer.frame;
                    frame.size.width = [orgStr size].width;
                    curLayer.frame = frame;
                    curLayer.string = orgStr;
                    [curLayer updateFrameBaseOnBase];
                    
                    [(EquationBlock *)gCurE.curParent updateFrameWidth:incrWidth :curLayer.roll];
                    [gCurE.root adjustElementPosition];
                    
                    gCurE.view.inpOrg = CGPointMake(curLayer.frame.origin.x, curLayer.frame.origin.y);
                    gCurE.view.cursor.frame = CGRectMake(gCurE.view.inpOrg.x, gCurE.view.inpOrg.y, CURSOR_W, gCurE.curFontH);
                    
                    curLayer.type = TEXTLAYER_EMPTY;
                    [curLayer.strLenTbl removeLastObject];
                    gCurE.txtInsIdx = 0;
                } else if (curLayer.strLenTbl.count == 1 && gCurE.txtInsIdx == 0) { // Empty layer
                    id pre = getPrevBlk(gCurE, curLayer);
                    EquationBlock *par = curLayer.parent;
                    if (curLayer.c_idx == 0 || [[par.children objectAtIndex:curLayer.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                        if (pre != nil) {
                            if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                                EquationTextLayer *layer = pre;
                                if (layer.is_base_expo == curLayer.is_base_expo) {
                                    (void)locaLastTxtLyr(gCurE, pre);
                                } else { //Switch from expo to base in a same text layer
                                    cfgEqnBySlctBlk(gCurE, layer, CGPointMake(layer.frame.origin.x + layer.frame.size.width - 1.0, layer.frame.origin.y + 1.0));
                                }
                            } else {
                                (void)locaLastTxtLyr(gCurE, pre);
                            }
                        } else {
                            return;
                        }
                    } else {
                        if (pre != nil) {
                            if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                                EquationTextLayer *l = pre;
                                if (l.expo != nil) {
                                    (void)locaLastTxtLyr(gCurE, l);
                                } else {
                                    if (l.strLenTbl.count == 2 || l.strLenTbl.count == 1) { // 1 char num/op/empty
                                        [gCurE removeElement:l];
                                    } else {
                                        CGFloat orgW = l.mainFrame.size.width;
                                        [l delNumCharAt:(int)l.strLenTbl.count - 1];
                                        CGFloat incrWidth = l.mainFrame.size.width - orgW;
                                        [(EquationBlock *)l.parent updateFrameWidth:incrWidth :l.roll];
                                        [gCurE.root adjustElementPosition];
                                        cfgEqnBySlctBlk(gCurE, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                                    }
                                }
                            } else {
                                (void)locaLastTxtLyr(gCurE, pre);
                            }
                        } else {
                            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                            return;
                        }
                    }
                } else { // Number > 1 char
                    CGFloat orgW = curLayer.mainFrame.size.width;
                    CGFloat offset = [curLayer delNumCharAt:gCurE.txtInsIdx--];
                    CGFloat incrWidth = curLayer.mainFrame.size.width - orgW;
                    [(EquationBlock *)gCurE.curParent updateFrameWidth:incrWidth :gCurE.curRoll];
                    [gCurE.root adjustElementPosition];
                    gCurE.view.inpOrg = CGPointMake(curLayer.frame.origin.x + offset, curLayer.frame.origin.y);
                    gCurE.view.cursor.frame = CGRectMake(gCurE.view.inpOrg.x, gCurE.view.inpOrg.y, CURSOR_W, gCurE.curFontH);
                    if (gCurE.txtInsIdx == 0) {
                        gCurE.insertCIdx = curLayer.c_idx;
                    }
                }
            } else { // expo == nil
                if (curLayer.strLenTbl.count == 2 && gCurE.txtInsIdx == 1) { // Number/Op/Paren
                    [gCurE removeElement:curLayer];
                } else if (curLayer.strLenTbl.count == 1 && gCurE.txtInsIdx == 0) { // Empty layer
                    [gCurE removeElement:curLayer];
                } else { // Number > 1 char
                    CGFloat orgW = curLayer.mainFrame.size.width;
                    CGFloat offset = [curLayer delNumCharAt:gCurE.txtInsIdx--];
                    CGFloat incrWidth = curLayer.mainFrame.size.width - orgW;
                    [(EquationBlock *)gCurE.curParent updateFrameWidth:incrWidth :gCurE.curRoll];
                    [gCurE.root adjustElementPosition];
                    gCurE.view.inpOrg = CGPointMake(curLayer.frame.origin.x + offset, curLayer.frame.origin.y);
                    gCurE.view.cursor.frame = CGRectMake(gCurE.view.inpOrg.x, gCurE.view.inpOrg.y, CURSOR_W, gCurE.curFontH);
                    if (gCurE.txtInsIdx == 0) {
                        gCurE.insertCIdx = curLayer.c_idx;
                    }
                }
            }
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
    } else if ([gCurE.curBlk isMemberOfClass:[Parentheses class]]) {
        Parentheses *p = gCurE.curBlk;
        if (gCurE.insertCIdx == p.c_idx) {
            id pre = getPrevBlk(gCurE, p);
            if (pre == nil) {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
            
            EquationBlock *par = p.parent;
            if (p.c_idx == 0 || [[par.children objectAtIndex:p.c_idx - 1] isMemberOfClass:[FractionBarLayer class]]) {
                if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *layer = pre;
                    if (layer.is_base_expo == p.is_base_expo) {
                        (void)locaLastTxtLyr(gCurE, pre);
                    } else { //Switch from expo to base in a same text layer
                        cfgEqnBySlctBlk(gCurE, layer, CGPointMake(layer.frame.origin.x + layer.frame.size.width - 1.0, layer.frame.origin.y + 1.0));
                    }
                } else if ([pre isMemberOfClass:[Parentheses class]]) {
                    Parentheses *p = pre;
                    cfgEqnBySlctBlk(gCurE, p, CGPointMake(p.frame.origin.x + p.frame.size.width - 1.0, p.frame.origin.y + 1.0));
                } else {
                    (void)locaLastTxtLyr(gCurE, pre);
                }
            } else {
                if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                    EquationTextLayer *l = pre;
                    if (l.expo != nil) {
                        (void)locaLastTxtLyr(gCurE, l);
                    } else {
                        if (l.strLenTbl.count == 2 || l.strLenTbl.count == 1) { // 1 char num/op/empty
                            [gCurE removeElement:l];
                        } else {
                            CGFloat orgW = l.mainFrame.size.width;
                            [l delNumCharAt:(int)l.strLenTbl.count - 1];
                            CGFloat incrWidth = l.mainFrame.size.width - orgW;
                            [(EquationBlock *)l.parent updateFrameWidth:incrWidth :l.roll];
                            [gCurE.root adjustElementPosition];
                            cfgEqnBySlctBlk(gCurE, l, CGPointMake(l.frame.origin.x + l.frame.size.width - 1.0, l.frame.origin.y + 1.0));
                        }
                    }
                } else if ([pre isMemberOfClass:[Parentheses class]]) {
                    [gCurE removeElement:pre];
                } else {
                    (void)locaLastTxtLyr(gCurE, pre);
                }
            }
        } else if (gCurE.insertCIdx == p.c_idx + 1) {
            [gCurE removeElement:p];
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
}

-(void)delBlock:(NSTimer *)timer{
    [self handleDelBtnClick];
}

-(void)btnDelLongPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        delBtnLongPressTmr = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(delBlock:) userInfo:nil repeats:YES];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if ([delBtnLongPressTmr isValid] == YES) {
            [delBtnLongPressTmr invalidate];
            delBtnLongPressTmr = nil;
        }
    }
}

- (void)handleReturnBtnClick {
    NSMutableString *str = equationToString(gCurE.root);
    if (str == nil) {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        return;
    }
    
    NSNumber *result = calculate(str);
    
    NSLog(@"%s%i>~%@~~~~~%@~~~~~", __FUNCTION__, __LINE__, str, result);
    
    if (result != nil) {
        [gCurE.root moveUp:gCurE.baseCharHight];
        
        gCurE.curFont = gCurE.baseFont;
        
        CGPoint pos = CGPointMake(gCurE.downLeftBasePoint.x, gCurE.downLeftBasePoint.y - gCurE.baseCharHight - 1.0);
        EquationTextLayer *l = [[EquationTextLayer alloc] init:@"=" :pos :gCurE :TEXTLAYER_OP];
        l.parent = gCurE.root;
        [gCurE.root.children addObject:l];
        [gCurE.view.layer addSublayer:l];
        
        pos.x += l.frame.size.width;
        
        l = [[EquationTextLayer alloc] init:[result stringValue] :pos :gCurE :TEXTLAYER_NUM];
        l.parent = gCurE.root;
        [gCurE.root.children addObject:l];
        [gCurE.view.layer addSublayer:l];
        
        gCurE.hasResult = YES;
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    
}

- (void)handleCleanBtnClick {
    [gCurE.root destroy];
    gCurE.curMode = MODE_INPUT;
    gCurE.curRoll = ROLL_NUMERATOR;
    gCurE.insertCIdx = 0;
    gCurE.txtInsIdx = 0;
    gCurE.guid_cnt = 0;
    gCurE.zoomInLvl = 0;
    gCurE.baseFont = [UIFont systemFontOfSize: getBaseFontSize(gCurE.zoomInLvl)];
    gCurE.superscriptFont = [UIFont systemFontOfSize:getBaseFontSize(gCurE.zoomInLvl) / 2.0];
    
    gCurE.baseCharWidth = gBaseCharWidthTbl[gCurE.zoomInLvl][8];
    gCurE.baseCharHight = gCurE.baseFont.lineHeight;
    
    gCurE.expoCharWidth = gExpoCharWidthTbl[gCurE.zoomInLvl][8];
    gCurE.expoCharHight = gCurE.superscriptFont.lineHeight;

    gCurE.curFont = gCurE.baseFont;

    CGPoint rootPos = CGPointMake(gCurE.downLeftBasePoint.x, gCurE.downLeftBasePoint.y - gCurE.baseCharHight - 1.0);
    gCurE.view.cursor.frame = CGRectMake(rootPos.x, rootPos.y, 3.0, gCurE.baseCharHight);
    gCurE.view.inpOrg = gCurE.view.cursor.frame.origin;

    gCurE.root = [[EquationBlock alloc] init:rootPos :gCurE];
    gCurE.root.roll = ROLL_ROOT;
    gCurE.root.parent = nil;
    gCurE.root.ancestor = gCurE;
    gCurE.curParent = gCurE.root;

    EquationTextLayer *layer = [[EquationTextLayer alloc] init:@"_" :rootPos :gCurE :TEXTLAYER_EMPTY];
    layer.parent = gCurE.root;
    gCurE.root.numerFrame = layer.frame;
    gCurE.root.mainFrame = layer.frame;
    
    layer.c_idx = 0;
    [gCurE.root.children addObject:layer];
    [gCurE.view.layer addSublayer:layer];
    gCurE.curTxtLyr = layer;
    gCurE.curBlk = layer;
}

- (void)handleWETLInput: (NSString *)pfx {
    CGFloat incrWidth = 0.0;
    
    if (gCurE.curTxtLyr != nil && gCurE.curTxtLyr.type == TEXTLAYER_EMPTY) {
        if (gCurE.curTxtLyr.expo == nil) {
            EquationBlock *cb = gCurE.curParent;
            [gCurE.curTxtLyr destroy];
            [cb.children removeObjectAtIndex:gCurE.curTxtLyr.c_idx];
            [cb updateCIdx];
            incrWidth -= gCurE.curTxtLyr.mainFrame.size.width;
        } else if ([gCurE.curTxtLyr.expo.children.firstObject isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *l = gCurE.curTxtLyr.expo.children.firstObject;
            if (l.type == TEXTLAYER_EMPTY) {
                EquationBlock *cb = gCurE.curParent;
                [gCurE.curTxtLyr destroy];
                [cb.children removeObjectAtIndex:gCurE.curTxtLyr.c_idx];
                [cb updateCIdx];
                incrWidth -= gCurE.curTxtLyr.mainFrame.size.width;
            } else {
                gCurE.curMode = MODE_INSERT;
                gCurE.insertCIdx = gCurE.curTxtLyr.c_idx;
            }
        } else {
            gCurE.curMode = MODE_INSERT;
            gCurE.insertCIdx = gCurE.curTxtLyr.c_idx;
        }
    }
    
    WrapedEqTxtLyr *wetl = [[WrapedEqTxtLyr alloc] init:pfx :gCurE.view.inpOrg :gCurE :self];
    
    incrWidth += wetl.mainFrame.size.width;
    
    //    if (orgLayer != nil && orgLayer.type == TEXTLAYER_EMPTY) {
    //        EquationBlock *cb = gCurE.curBlk;
    //        [orgLayer destroy];
    //        [cb.children removeObjectAtIndex:orgLayer.c_idx];
    //        [cb updateCIdx];
    //        incrWidth -= orgLayer.mainFrame.size.width;
    //    }
    
    
    if(gCurE.curMode == MODE_INPUT) {
        EquationBlock *eBlock = gCurE.curParent;
        
        wetl.c_idx = eBlock.children.count;
        
        [eBlock.children addObject:wetl];
    } else if(gCurE.curMode == MODE_INSERT) {
        EquationBlock *eBlock = gCurE.curParent;
        
        [eBlock.children insertObject:wetl atIndex: gCurE.insertCIdx];
        
        /*Update c_idx*/
        [eBlock updateCIdx];
    } else if(gCurE.curMode == MODE_DUMP_ROOT) {
        EquationBlock *newRoot = [[EquationBlock alloc] init:gCurE];
        newRoot.roll = ROLL_ROOT;
        newRoot.parent = nil;
        newRoot.numerFrame = gCurE.root.mainFrame;
        newRoot.numerTopHalf = gCurE.root.mainFrame.size.height / 2.0;
        newRoot.numerBtmHalf = gCurE.root.mainFrame.size.height / 2.0;
        newRoot.mainFrame = newRoot.numerFrame;
        gCurE.root.roll = ROLL_NUMERATOR;
        gCurE.root.parent = newRoot;
        if (gCurE.insertCIdx == 0) {
            gCurE.root.c_idx = 1;
            wetl.c_idx = 0;
            [newRoot.children addObject:wetl];
            [newRoot.children addObject:gCurE.root];
            gCurE.curMode = MODE_INSERT;
        } else {
            gCurE.root.c_idx = 0;
            [newRoot.children addObject:gCurE.root];
            wetl.c_idx = 1;
            [newRoot.children addObject:wetl];
            gCurE.curMode = MODE_INPUT;
        }
        gCurE.curParent = newRoot;
        gCurE.root = newRoot;
    } else if(gCurE.curMode == MODE_DUMP_RADICAL) {
        RadicalBlock *rBlock = gCurE.curParent;
        EquationBlock *orgRootRoot = rBlock.content;
        EquationBlock *newRootRoot = [[EquationBlock alloc] init:gCurE];
        newRootRoot.roll = ROLL_ROOT_ROOT;
        newRootRoot.parent = rBlock;
        newRootRoot.numerFrame = orgRootRoot.mainFrame;
        newRootRoot.numerTopHalf = orgRootRoot.mainFrame.size.height / 2.0;
        newRootRoot.numerBtmHalf = orgRootRoot.mainFrame.size.height / 2.0;
        newRootRoot.mainFrame = newRootRoot.numerFrame;
        orgRootRoot.roll = ROLL_NUMERATOR;
        orgRootRoot.parent = newRootRoot;
        
        if (gCurE.insertCIdx == 0) {
            orgRootRoot.c_idx = 1;
            wetl.c_idx = 0;
            [newRootRoot.children addObject:wetl];
            [newRootRoot.children addObject:orgRootRoot];
            gCurE.curMode = MODE_INSERT;
        } else {
            orgRootRoot.c_idx = 0;
            [newRootRoot.children addObject:orgRootRoot];
            wetl.c_idx = 1;
            [newRootRoot.children addObject:wetl];
            gCurE.curMode = MODE_INPUT;
        }
        
        rBlock.content = newRootRoot;
        gCurE.curParent = newRootRoot;
    } else if(gCurE.curMode == MODE_DUMP_EXPO) {
        EquationTextLayer *layer = gCurE.curParent;
        EquationBlock *orgExpo = layer.expo;
        EquationBlock *newExpo = [[EquationBlock alloc] init:gCurE];
        newExpo.roll = ROLL_EXPO_ROOT;
        newExpo.parent = layer;
        newExpo.numerFrame = orgExpo.mainFrame;
        newExpo.numerTopHalf = orgExpo.mainFrame.size.height / 2.0;
        newExpo.numerBtmHalf = orgExpo.mainFrame.size.height / 2.0;
        newExpo.mainFrame = newExpo.numerFrame;
        orgExpo.roll = ROLL_NUMERATOR;
        orgExpo.parent = newExpo;
        
        if (gCurE.insertCIdx == 0) {
            wetl.c_idx = 0;
            [newExpo.children addObject:wetl];
            orgExpo.c_idx = 1;
            [newExpo.children addObject:orgExpo];
            gCurE.curMode = MODE_INSERT;
        } else {
            orgExpo.c_idx = 0;
            [newExpo.children addObject:orgExpo];
            wetl.c_idx = 1;
            [newExpo.children addObject:wetl];
            gCurE.curMode = MODE_INPUT;
        }
        
        layer.expo = newExpo;
        gCurE.curParent = newExpo;
    } else if(gCurE.curMode == MODE_DUMP_WETL) {
        WrapedEqTxtLyr *orgWETL = gCurE.curParent;
        EquationBlock *orgWrapRoot = orgWETL.content;
        EquationBlock *newWrapRoot = [[EquationBlock alloc] init:gCurE];
        newWrapRoot.roll = ROLL_ROOT_ROOT;
        newWrapRoot.parent = orgWETL;
        newWrapRoot.numerFrame = orgWrapRoot.mainFrame;
        newWrapRoot.numerTopHalf = orgWrapRoot.mainFrame.size.height / 2.0;
        newWrapRoot.numerBtmHalf = orgWrapRoot.mainFrame.size.height / 2.0;
        newWrapRoot.mainFrame = newWrapRoot.numerFrame;
        orgWrapRoot.roll = ROLL_NUMERATOR;
        orgWrapRoot.parent = newWrapRoot;
        
        if (gCurE.insertCIdx == 0) {
            orgWrapRoot.c_idx = 1;
            wetl.c_idx = 0;
            [newWrapRoot.children addObject:wetl];
            [newWrapRoot.children addObject:orgWrapRoot];
            gCurE.curMode = MODE_INSERT;
        } else {
            orgWrapRoot.c_idx = 0;
            [newWrapRoot.children addObject:orgWrapRoot];
            wetl.c_idx = 1;
            [newWrapRoot.children addObject:wetl];
            gCurE.curMode = MODE_INPUT;
        }
        
        orgWETL.content = newWrapRoot;
        gCurE.curParent = newWrapRoot;
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    
    wetl.parent = gCurE.curParent;
    
    [(EquationBlock *)gCurE.curParent updateFrameWidth:incrWidth :gCurE.curRoll];
    [gCurE.root adjustElementPosition];
    
    gCurE.insertCIdx = 1;
    gCurE.txtInsIdx = 0;
    gCurE.curMode = MODE_INPUT;
    gCurE.curRoll = ROLL_NUMERATOR;
    gCurE.curParent = wetl.content;
    gCurE.view.inpOrg = ((EquationBlock *)gCurE.curParent).mainFrame.origin;
    gCurE.view.cursor.frame = CGRectMake(gCurE.view.inpOrg.x, gCurE.view.inpOrg.y, CURSOR_W, gCurE.curFontH);
    
    if ((gCurE.root.mainFrame.origin.y < 0.0 || gCurE.root.mainFrame.origin.x + gCurE.root.mainFrame.size.width > scnWidth) && gCurE.zoomInLvl < 2) {
        gCurE.zoomInLvl++;
        [self zoom];
    }
}

-(void)btnClicked: (UIButton *)btn {
    
    if([[btn currentTitle]  isEqual: @"DUMP"]) {
        [gCurE dumpEverything:gCurE.root];
        NSLog(@"InputX: %.1f InputY: %.1f~~~~~~~~~~~", gCurE.view.inpOrg.x, gCurE.view.inpOrg.y);
    } else if([[btn currentTitle]  isEqual: @"DEBUG"]) {
        drawFrame(self, gCurE.view, gCurE.root);
    } else if([[btn currentTitle]  isEqual: @"0"]) {
        [self handleNumBtnClick: @"0"];
    } else if([[btn currentTitle]  isEqual: @"1"]) {
        [self handleNumBtnClick: @"1"];
    } else if([[btn currentTitle]  isEqual: @"2"]) {
        [self handleNumBtnClick: @"2"];
    } else if([[btn currentTitle]  isEqual: @"3"]) {
        [self handleNumBtnClick: @"3"];
    } else if([[btn currentTitle]  isEqual: @"4"]) {
        [self handleNumBtnClick: @"4"];
    } else if([[btn currentTitle]  isEqual: @"5"]) {
        [self handleNumBtnClick: @"5"];
    } else if([[btn currentTitle]  isEqual: @"6"]) {
        [self handleNumBtnClick: @"6"];
    } else if([[btn currentTitle]  isEqual: @"7"]) {
        [self handleNumBtnClick: @"7"];
    } else if([[btn currentTitle]  isEqual: @"8"]) {
        [self handleNumBtnClick: @"8"];
    } else if([[btn currentTitle]  isEqual: @"9"]) {
        [self handleNumBtnClick: @"9"];
    } else if([[btn currentTitle]  isEqual: @"+"]) {
        [self handleOpBtnClick: @"+"];
    } else if([[btn currentTitle]  isEqual: @"-"]) {
        [self handleOpBtnClick: @"-"];
    } else if([[btn currentTitle]  isEqual: @"×"]) {
        [self handleOpBtnClick: @"×"];
    } else if([[btn currentTitle]  isEqual: @"÷"]) {
        [self handleOpBtnClick: @"÷"];
    } else if([[btn currentTitle]  isEqual: @"Root"]) {
        [self handleRootBtnClick:3];
    } else if([[btn currentTitle]  isEqual: @"x^"]) {
        [self handlePowBtnClick];
    } else if([[btn currentTitle]  isEqual: @"("]) {
        [self handleParenthBtnClick: LEFT_PARENTH];
    } else if([[btn currentTitle]  isEqual: @")"]) {
        [self handleParenthBtnClick: RIGHT_PARENTH];
    } else if([[btn currentTitle]  isEqual: @"<-"]) {
        [self handleDelBtnClick];
    } else if([[btn currentTitle]  isEqual: @"·"]) {
        //[self handleNumBtnClick: @"."];
        CALayer *test = [[CALayer alloc] init];
        test.contentsScale = [UIScreen mainScreen].scale;
        test.frame = CGRectMake(10, 10, 10, 40);
        test.name = @"parentheses";
        test.delegate = self;
        [gCurE.view.layer addSublayer: test];
        [test setNeedsDisplay];
    } else if([[btn currentTitle]  isEqual: @"%"]) {
        gCurE.zoomInLvl = 1;
        [self zoom];
    } else if([[btn currentTitle]  isEqual: @"="]) {
        [self handleReturnBtnClick];
    } else if([[btn currentTitle]  isEqual: @"save"]) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:gCurE];
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user setObject:data forKey:[NSString stringWithFormat:@"equation%li", (long)gCurEqIdx]];
        [user setObject:@"1.0" forKey:@"version"];
        [user setInteger:gCurEqIdx forKey:@"gCurEqIdx"];
        NSLog(@"%s%i>~%i~~~~~~~~~~", __FUNCTION__, __LINE__, [user synchronize]);
    } else if([[btn currentTitle]  isEqual: @"load"]) {
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        gCurEqIdx = [user integerForKey:@"gCurEqIdx"];
        NSData *data = [user objectForKey:[NSString stringWithFormat:@"equation%li", (long)gCurEqIdx]];
        if (data != nil) {
            Equation *eq = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [eq dumpEverything:eq.root];
            [eq.root reorganize:eq :self];
            
            CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"hidden"];
            anim.fromValue = [NSNumber numberWithBool:YES];
            anim.toValue = [NSNumber numberWithBool:NO];
            anim.duration = 0.5;
            anim.autoreverses = YES;
            anim.repeatCount = HUGE_VALF;
            [eq.view.cursor addAnimation:anim forKey:nil];
            [eq.view.layer addSublayer:eq.view.cursor];
            eq.view.cursor.delegate = self;
            [eq.view.cursor setNeedsDisplay];
            
            //locaLastTxtLyr(eq, eq.root);
            DisplayView *orgView = gCurE.view;
            [UIView transitionFromView:orgView toView:eq.view duration:0.4 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
                // What to do when its finished.
            }];
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
    } else if([[btn currentTitle]  isEqual: @"reset"]) {
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSDictionary *dictionary = [user dictionaryRepresentation];
        for(NSString* key in [dictionary allKeys]){
            [user removeObjectForKey:key];
        }
        [user synchronize];
    } else if([[btn currentTitle]  isEqual: @"C"]) {
        [self handleCleanBtnClick];
    } else if([[btn currentTitle]  isEqual: @"COS"]) {
        [self handleWETLInput:@"COS"];
    } else
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
}

-(void)zoom {
    if (gCurE.hasResult) {
        return;
    }
    
    gCurE.baseFont = [UIFont systemFontOfSize: getBaseFontSize(gCurE.zoomInLvl)];
    gCurE.superscriptFont = [UIFont systemFontOfSize:getBaseFontSize(gCurE.zoomInLvl) / 2.0];
    
    gCurE.baseCharWidth = gBaseCharWidthTbl[gCurE.zoomInLvl][8];
    gCurE.baseCharHight = gCurE.baseFont.lineHeight;
    
    gCurE.expoCharWidth = gExpoCharWidthTbl[gCurE.zoomInLvl][8];
    gCurE.expoCharHight = gCurE.superscriptFont.lineHeight;
    
    [gCurE.root updateElementSize:gCurE];
    CGRect f = gCurE.root.mainFrame;
    f.origin.x = gCurE.downLeftBasePoint.x;
    f.origin.y = gCurE.downLeftBasePoint.y - f.size.height - 1.0;
    gCurE.root.mainFrame = f;
    [gCurE.root adjustElementPosition];
    
    if ([gCurE.curBlk isMemberOfClass:[EquationBlock class]]) {
        EquationBlock *eb = gCurE.curBlk;
        cfgEqnBySlctBlk(gCurE, eb.bar, CGPointMake(eb.bar.frame.origin.x + eb.bar.frame.size.width - 1.0, eb.bar.frame.origin.y + 1.0));
    } else if ([gCurE.curBlk isMemberOfClass:[EquationTextLayer class]]) {
        EquationTextLayer *l = gCurE.curBlk;
        cfgEqnBySlctBlk(gCurE, l, CGPointMake(l.mainFrame.origin.x + l.mainFrame.size.width - 1.0, l.mainFrame.origin.y + 1.0));
    } else if ([gCurE.curBlk isMemberOfClass:[RadicalBlock class]]) {
        RadicalBlock *rb = gCurE.curBlk;
        cfgEqnBySlctBlk(gCurE, rb, CGPointMake(rb.frame.origin.x + rb.frame.size.width - 1.0, rb.frame.origin.y + 1.0));
    } else if ([gCurE.curBlk isMemberOfClass:[WrapedEqTxtLyr class]]) {
        WrapedEqTxtLyr *wetl = gCurE.curBlk;
        cfgEqnBySlctBlk(gCurE, wetl, CGPointMake(wetl.right_parenth.frame.origin.x + wetl.right_parenth.frame.size.width - 1.0, wetl.right_parenth.frame.origin.y + 1.0));
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    if ([layer.name isEqual: @"btnBorderLayer"]) {
        CGContextSetGrayStrokeColor(ctx, 0.0, 1.0);
        CGContextSetLineWidth(ctx, 0.5);
        CGFloat col = scnWidth / 5;
        CGFloat row = scnHeight / 10;
        CGPoint points[] = {CGPointMake(0, row), CGPointMake(scnWidth, row), CGPointMake(0, row * 2), CGPointMake(scnWidth, row * 2), CGPointMake(0, row * 3), CGPointMake(scnWidth, row * 3), CGPointMake(0, row * 4), CGPointMake(col * 4, row * 4), CGPointMake(col, 0), CGPointMake(col, scnHeight / 2), CGPointMake(col * 2, 0), CGPointMake(col * 2, scnHeight / 2), CGPointMake(col * 3, 0), CGPointMake(col * 3, scnHeight / 2), CGPointMake(col * 4, 0), CGPointMake(col * 4, scnHeight / 2)};
        CGContextStrokeLineSegments(ctx, points, 16);
    } else if ([layer.name isEqual: @"cursorLayer"]) {
        CGContextSetGrayStrokeColor(ctx, 0.0, 1.0);
        CGContextSetLineWidth(ctx, layer.frame.size.width);
        
        CGPoint points[] = {CGPointMake(0, 0), CGPointMake(0, layer.frame.size.height)};
        CGContextStrokeLineSegments(ctx, points, 2);
    } else if ([layer.name isEqual: @"/"]) {
        CGContextSetGrayStrokeColor(ctx, 0.0, 1.0);
        CGContextSetLineWidth(ctx, 1.0);
        FractionBarLayer *bar = (FractionBarLayer *)layer;
        CGPoint points[] = {CGPointMake(0, bar.frame.size.height/2.0 - 1.0), CGPointMake(bar.frame.size.width, bar.frame.size.height/2.0 - 1.0)};
        CGContextStrokeLineSegments(ctx, points, 2);
    }else if ([layer.name isEqual: @"radical"]) {
        CGContextSetGrayStrokeColor(ctx, 0.0, 1.0);
        CGContextSetLineWidth(ctx, 1.0);
        RadicalBlock *rBlock = (RadicalBlock *)layer;
        CGFloat margineL = RADICAL_MARGINE_L_PERC * rBlock.frame.size.height;
//        CGPoint points[] = {CGPointMake(rBlock.frame.size.width, 1.0), CGPointMake(margineL, 1.0),
//            CGPointMake(margineL, 1.0), CGPointMake(margineL / 2.0, rBlock.frame.size.height - 2.0),
//            CGPointMake(margineL / 2.0, rBlock.frame.size.height - 2.0), CGPointMake(margineL/5.0, rBlock.frame.size.height * 0.75),
//            CGPointMake(margineL / 5.0, rBlock.frame.size.height * 0.75), CGPointMake(0.0, rBlock.frame.size.height * 0.85)};
//        CGContextStrokeLineSegments(ctx, points, 8);
        CGPoint points[] = {CGPointMake(rBlock.frame.size.width, 1.0), CGPointMake(margineL, 1.0),
            CGPointMake(margineL, 1.0), CGPointMake(margineL / 2.0, rBlock.frame.size.height - 2.0),
            CGPointMake(margineL / 2.0, rBlock.frame.size.height - 2.0), CGPointMake(1.0, rBlock.frame.size.height * 0.7)};
        CGContextStrokeLineSegments(ctx, points, 6);
    } else if ([layer.name isEqual: @"drawframe"]) {
        CGContextSetRGBStrokeColor(ctx, 0, 0, 0.7, 1);
        CGContextSetLineWidth(ctx, 0.5);
        
        CGPoint points[] = {CGPointMake(0.0, 0.0), CGPointMake(layer.frame.size.width - 0.0, 0.0),
            CGPointMake(layer.frame.size.width - 0.5, 0.0), CGPointMake(layer.frame.size.width - 0.5, layer.frame.size.height),
            CGPointMake(layer.frame.size.width - 0.5, layer.frame.size.height - 0.5), CGPointMake(0.5, layer.frame.size.height - 0.5),
            CGPointMake(0.5, layer.frame.size.height), CGPointMake(0.5, 0.0)};
        CGContextStrokeLineSegments(ctx, points, 8);
    } else if ([layer.name isEqual: @"parentheses"]) {
        Parentheses *p = (Parentheses *)layer;
        CGContextSetRGBStrokeColor(ctx, 0, 0, 1, 1);
        CGContextSetLineCap(ctx, kCGLineCapRound);
        CGContextSetLineWidth(ctx, 2.0);
        if (p.l_or_r == LEFT_PARENTH) {
            CGContextMoveToPoint(ctx, p.frame.size.width - 2, 2);
            CGContextAddQuadCurveToPoint(ctx, 0.0, layer.frame.size.height / 2.0, layer.frame.size.width - 2.0, layer.frame.size.height - 2.0);
            CGContextStrokePath(ctx);
        } else {
            CGContextMoveToPoint(ctx, 2, 2);
            CGContextAddQuadCurveToPoint(ctx, layer.frame.size.width, layer.frame.size.height / 2.0, 2.0, layer.frame.size.height - 2.0);
            CGContextStrokePath(ctx);
        }
        
    } else
        NSLog(@"%s%i>~~ERR~%@~~~~~~~~", __FUNCTION__, __LINE__, layer.name);
}

@end
