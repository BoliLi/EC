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


static UIView *testview;

@interface ViewController ()

@end

@implementation ViewController
@synthesize buttonFont;
@synthesize mainKbView;
@synthesize secondKbView;
@synthesize kbConView;
@synthesize dspConView;
@synthesize borderLayer;
@synthesize E;
@synthesize scnWidth;
@synthesize scnHeight;
@synthesize statusBarHeight;
@synthesize testeb;
@synthesize delBtnLongPressTmr;

-(void)handleTap: (UITapGestureRecognizer *)gesture {
    //NSUInteger touchNum = [gesture numberOfTouches];
    //NSUInteger tapNum = [gesture numberOfTapsRequired];
    CGPoint curPoint = [gesture locationOfTouch:0 inView: E.view];
    NSLog(@"%s%i~[%.1f, %.1f]~~~~~~~~~~", __FUNCTION__, __LINE__, curPoint.x, curPoint.y);
    id b = [E lookForElementByPoint:E.root :curPoint];
    if (b != nil) {
        cfgEqnBySlctBlk(E, b, curPoint);
    } else { //Tap outside
        NSLog(@"%s%i~~~~~~~~~~~", __FUNCTION__, __LINE__);
        if (E.root.children.count != 0) {
            
            E.curFont = E.baseFont;
            
            if (E.root.bar != nil) {//Root block has denominator
                CGFloat tmp = E.root.mainFrame.size.height;
                E.view.cursor.frame = CGRectMake(E.root.mainFrame.origin.x + E.root.mainFrame.size.width, E.root.mainFrame.origin.y, CURSOR_W, tmp);
                CGFloat x = E.root.bar.frame.origin.x + E.root.bar.frame.size.width;
                CGFloat y = E.root.numerFrame.origin.y + E.root.numerFrame.size.height - E.curFontH / 2.0;
                E.view.inpOrg = CGPointMake(x, y);
                E.curMode = MODE_DUMP_ROOT;
                E.curTxtLyr = nil;
                E.curBlk = E.root;
                E.curRoll = ROLL_NUMERATOR;
                NSLog(@"%s%i~Tapped outside fraction. Root block has denominator.~CIDX: %lu~Mode: %i~Roll: %i~~", __FUNCTION__, __LINE__, (unsigned long)E.insertCIdx, E.curMode, E.curRoll);
            } else {
                id block = [E.root.children lastObject];
                if ([block isMemberOfClass: [EquationTextLayer class]]) {
                    EquationTextLayer *layer = block;
                    
                    E.curMode = MODE_INPUT;
                    
                    if (layer.type == TEXTLAYER_OP) {
                        CGFloat x = layer.frame.origin.x + layer.frame.size.width;
                        CGFloat y = layer.frame.origin.y;
                        E.view.inpOrg = CGPointMake(x, y);
                        CGFloat tmp = layer.frame.size.height;
                        E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, CURSOR_W, tmp);
                        E.curTxtLyr = nil;
                    } else if (layer.type == TEXTLAYER_NUM) {
                        if (layer.expo == nil) {
                            CGFloat x = layer.frame.origin.x + layer.frame.size.width;
                            CGFloat y = layer.frame.origin.y;
                            E.view.inpOrg = CGPointMake(x, y);
                            CGFloat tmp = layer.frame.size.height;
                            E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, CURSOR_W, tmp);
                            E.curTxtLyr = layer;
                        } else {
                            CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                            CGFloat y = layer.frame.origin.y;
                            E.view.inpOrg = CGPointMake(x, y);
                            CGFloat tmp = layer.mainFrame.size.height;
                            E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, layer.mainFrame.origin.y, CURSOR_W, tmp);
                            E.curTxtLyr = nil;
                        }
                    } else if (layer.type == TEXTLAYER_EMPTY) {
                        if (layer.expo == nil) {
                            CGFloat x = layer.frame.origin.x;
                            CGFloat y = layer.frame.origin.y;
                            E.view.inpOrg = CGPointMake(x, y);
                            CGFloat tmp = layer.frame.size.height;
                            E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, CURSOR_W, tmp);
                            E.curTxtLyr = layer;
                        } else {
                            CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                            CGFloat y = layer.frame.origin.y;
                            E.view.inpOrg = CGPointMake(x, y);
                            CGFloat tmp = layer.mainFrame.size.height;
                            E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, layer.mainFrame.origin.y, CURSOR_W, tmp);
                            E.curTxtLyr = nil;
                        }
                    } else
                        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    E.curRoll = layer.roll;
                    E.curParent = layer.parent;
                    E.curBlk = layer;
                    NSLog(@"%s%i~Tapped outside fraction. Last obj is text layer.~Id: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, E.curTxtLyr.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((EquationBlock *)E.curParent).guid);
                } else if ([block isMemberOfClass: [EquationBlock class]]) {
                    EquationBlock *b = block;
                    E.curMode = MODE_INPUT;
                    E.curParent = b.parent;
                    E.curRoll = b.roll;
                    E.curTxtLyr = nil;
                    E.curBlk = b;
                    CGFloat x = b.bar.frame.origin.x + b.bar.frame.size.width;
                    CGFloat y = b.numerFrame.origin.y + b.numerFrame.size.height - E.curFontH / 2.0;
                    E.view.inpOrg = CGPointMake(x, y);
                    CGFloat tmp = b.mainFrame.size.height;
                    E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, b.mainFrame.origin.y, CURSOR_W, tmp);
                    NSLog(@"%s%i~Tapped outside fraction. Last obj is EquationBlock.~Id: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, b.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((EquationBlock *)E.curParent).guid);
                } else if ([block isMemberOfClass: [RadicalBlock class]]) {
                    RadicalBlock *b = block;
                    E.curMode = MODE_INPUT;
                    E.curParent = b.parent;
                    E.curRoll = b.roll;
                    E.curTxtLyr = nil;
                    E.curBlk = b;
                    CGFloat x = b.frame.origin.x + b.frame.size.width;
                    CGFloat y = b.frame.origin.y + b.frame.size.height / 2.0 - E.curFontH / 2.0;
                    E.view.inpOrg = CGPointMake(x, y);
                    CGFloat tmp = b.frame.size.height;
                    E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, b.frame.origin.y, CURSOR_W, tmp);
                    NSLog(@"%s%i~Tapped outside fraction. Last obj is RadicalBlock.~Id: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, b.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((EquationBlock *)E.curParent).guid);
                } else {
                    NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
            }
        }
    }
}

-(void)handleDspViewSwipeRight: (UISwipeGestureRecognizer *)gesture {
    NSLog(@"[%s%i]~~~~~~~~~~~", __FUNCTION__, __LINE__);
    DisplayView *orgView = E.view;
    gCurEqIdx--;
    if (gCurEqIdx < 0) {
        gCurEqIdx = 15;
    }
    E = [gEquationList objectAtIndex:gCurEqIdx];
    [E.view.cursor removeAllAnimations];
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"hidden"];
    anim.fromValue = [NSNumber numberWithBool:YES];
    anim.toValue = [NSNumber numberWithBool:NO];
    anim.duration = 0.5;
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VALF;
    [E.view.cursor addAnimation:anim forKey:nil];
    [UIView transitionFromView:orgView toView:E.view duration:0.4 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
        // What to do when its finished.
    }];
}

-(void)handleDspViewSwipeLeft: (UISwipeGestureRecognizer *)gesture {
    NSLog(@"[%s%i]~~~~~~~~~~~", __FUNCTION__, __LINE__);
    DisplayView *orgView = E.view;
    gCurEqIdx++;
    gCurEqIdx %= 16;
    E = [gEquationList objectAtIndex:gCurEqIdx];
    [E.view.cursor removeAllAnimations];
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"hidden"];
    anim.fromValue = [NSNumber numberWithBool:YES];
    anim.toValue = [NSNumber numberWithBool:NO];
    anim.duration = 0.5;
    anim.autoreverses = YES;
    anim.repeatCount = HUGE_VALF;
    [E.view.cursor addAnimation:anim forKey:nil];
    [UIView transitionFromView:orgView toView:E.view duration:0.4 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
        // What to do when its finished.
    }];
}

-(void)handleKbViewSwipeRight: (UISwipeGestureRecognizer *)gesture {
    NSLog(@"%s%i>~~~~~~~~~~~", __FUNCTION__, __LINE__);
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
    NSLog(@"%s%i>~~~~~~~~~~~", __FUNCTION__, __LINE__);
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
    CGRect cursorFrame = CGRectMake(1, (scnHeight / 2) - statusBarHeight - 30.0, 0.0, 0.0); //Size will update in Equation init
    CGPoint rootPos = CGPointMake(1, (scnHeight / 2) - statusBarHeight - 30.0);
    for (int i = 0; i < 16; i++) {
        E = [[Equation alloc] init:rootPos :dspFrame :cursorFrame :self];
        [gEquationList addObject:E];
        //[dspConView addSubview:E.view];
    }
    E = gEquationList.firstObject;
    
    [dspConView addSubview:E.view];

    kbConView = [[UIView alloc] initWithFrame:CGRectMake(0, scnHeight / 2, scnWidth, scnHeight / 2)];
    kbConView.tag = 2;
    kbConView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:kbConView];
    
    secondKbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, scnWidth, scnHeight / 2)];
    secondKbView.backgroundColor = [UIColor whiteColor];
    
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleKbViewSwipeRight:)];
    right.numberOfTouchesRequired = 1;
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [secondKbView addGestureRecognizer:right];
    
    buttonFont = [UIFont systemFontOfSize: 20];
    NSArray *btnTitleArr = [NSArray arrayWithObjects:@"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", @"TBD", nil];
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
    
    btnTitleArr = [NSArray arrayWithObjects:@"DUMP", @"DEBUG", @"Root", @"<-", @"7", @"8", @"9", @"÷", @"4", @"5", @"6", @"×", @"1", @"2", @"3", @"-", @"%", @"0", @"·", @"+", @"x^", @"(", @")", @"=", nil];
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
    
    if (E.curTxtLyr == nil) {
        
        EquationTextLayer *tLayer = [[EquationTextLayer alloc] init:num :E.view.inpOrg :E :TEXTLAYER_NUM];
        
        if ([E.curParent isMemberOfClass: [EquationBlock class]]) {
            NSLog(@"%s%i~Input Num %@ with new text layer.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, num, tLayer.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((EquationBlock *)E.curParent).guid);
        } else if ([E.curParent isMemberOfClass: [RadicalBlock class]]) {
            NSLog(@"%s%i~Input Num %@ with new text layer.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, num, tLayer.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((RadicalBlock *)E.curParent).guid);
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        incrWidth = tLayer.frame.size.width;
        
        if(E.curMode == MODE_INPUT) {
            EquationBlock *block = E.curParent;

            tLayer.c_idx = block.children.count;
            [block.children addObject:tLayer];
        } else if(E.curMode == MODE_INSERT) {
            //NSLog(@"%s%i~~~%lu~~~~~~~~", __FUNCTION__, __LINE__, (unsigned long)E.insertCIdx);
            EquationBlock *block = E.curParent;

            tLayer.c_idx = E.insertCIdx;
            [block.children insertObject:tLayer atIndex:tLayer.c_idx];
            /*Update c_idx*/
            [block updateCIdx];
            E.insertCIdx += 1;
        } else if(E.curMode == MODE_DUMP_ROOT) {
            EquationBlock *block = [[EquationBlock alloc] init:E];
            block.roll = ROLL_ROOT;
            block.parent = nil;
            block.numerFrame = E.root.mainFrame;
            block.numerTopHalf = E.root.mainFrame.size.height / 2.0;
            block.numerBtmHalf = E.root.mainFrame.size.height / 2.0;
            block.mainFrame = block.numerFrame;
            E.root.roll = ROLL_NUMERATOR;
            E.root.parent = block;
            E.root.c_idx = 0;
            [block.children addObject:E.root];

            tLayer.c_idx = 1;
            [block.children addObject:tLayer];
            E.root = block;
            E.curParent = block;
            E.curMode = MODE_INPUT;
        } else if(E.curMode == MODE_DUMP_RADICAL) {
            RadicalBlock *rBlock = E.curParent;
            EquationBlock *eBlock = rBlock.content;
            EquationBlock *newBlock = [[EquationBlock alloc] init:E];
            newBlock.roll = ROLL_ROOT_ROOT;
            newBlock.parent = rBlock;
            newBlock.numerFrame = eBlock.mainFrame;
            newBlock.numerTopHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.numerBtmHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.mainFrame = newBlock.numerFrame;
            eBlock.roll = ROLL_NUMERATOR;
            eBlock.parent = newBlock;
            eBlock.c_idx = 0;
            [newBlock.children addObject:eBlock];

            tLayer.c_idx = 1;
            [newBlock.children addObject:tLayer];
            rBlock.content = newBlock;
            E.curParent = newBlock;
            E.curMode = MODE_INPUT;
        } else if(E.curMode == MODE_DUMP_EXPO) {
            EquationTextLayer *layer = E.curParent;
            EquationBlock *eBlock = layer.expo;
            EquationBlock *newBlock = [[EquationBlock alloc] init:E];
            newBlock.roll = ROLL_EXPO_ROOT;
            newBlock.parent = layer;
            newBlock.numerFrame = eBlock.mainFrame;
            newBlock.numerTopHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.numerBtmHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.mainFrame = newBlock.numerFrame;
            eBlock.roll = ROLL_NUMERATOR;
            eBlock.parent = newBlock;
            eBlock.c_idx = 0;
            [newBlock.children addObject:eBlock];

            tLayer.c_idx = 1;
            [newBlock.children addObject:tLayer];
            layer.expo = newBlock;
            E.curParent = newBlock;
            E.curMode = MODE_INPUT;
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        tLayer.parent = E.curParent;
        [E.view.layer addSublayer:tLayer];
        E.curTxtLyr = tLayer;
        E.curBlk = tLayer;
        E.txtInsIdx = 1;
        cursorOffset = tLayer.mainFrame.size.width;
    } else {
        NSLog(@"%s%i~Input Num %@ with exist text layer.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, num, E.curTxtLyr.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((EquationBlock *)E.curParent).guid);
        if (E.curTxtLyr.type == TEXTLAYER_EMPTY) {
            CGFloat orgW = E.curTxtLyr.mainFrame.size.width;
            cursorOffset = [E.curTxtLyr addNumChar:num];
            incrWidth += E.curTxtLyr.mainFrame.size.width - orgW;
            E.txtInsIdx = 1;
        } else {
            CGFloat orgW = E.curTxtLyr.mainFrame.size.width;
            if (E.txtInsIdx == E.curTxtLyr.strLenTbl.count - 1) {
                cursorOffset = [E.curTxtLyr addNumChar:num];
            } else {
                cursorOffset = [E.curTxtLyr insertNumChar:num at:E.txtInsIdx];
            }
            E.txtInsIdx++;
            incrWidth += E.curTxtLyr.mainFrame.size.width - orgW;
        }
        
    }
    
    /* Update frame info of current block */
    [(EquationBlock *)E.curParent updateFrameWidth:incrWidth :E.curRoll];
    [E adjustEveryThing:E.root];
    
    /* Move cursor */
    CGFloat cursorOrgX = E.curTxtLyr.frame.origin.x + cursorOffset;
    CGFloat cursorOrgY = E.curTxtLyr.frame.origin.y;
    
    E.view.cursor.frame = CGRectMake(cursorOrgX, cursorOrgY, CURSOR_W, E.curFontH);
    E.view.inpOrg = CGPointMake(cursorOrgX, cursorOrgY);
}

- (void)handleOpBtnClick : (NSString *)op {
    
    
    if ([op isEqual: @"×"] || [op isEqual: @"+"] || [op isEqual: @"-"]) {
        CGFloat incrWidth = 0.0;
        
        if (E.curTxtLyr != nil && E.curTxtLyr.type == TEXTLAYER_EMPTY) {
            if (E.curTxtLyr.expo == nil) {
                EquationBlock *cb = E.curParent;
                [E.curTxtLyr destroy];
                [cb.children removeObjectAtIndex:E.curTxtLyr.c_idx];
                [cb updateCIdx];
                incrWidth -= E.curTxtLyr.mainFrame.size.width;
            } else if ([E.curTxtLyr.expo.children.firstObject isMemberOfClass:[EquationTextLayer class]]) {
                EquationTextLayer *l = E.curTxtLyr.expo.children.firstObject;
                if (l.type == TEXTLAYER_EMPTY) {
                    EquationBlock *cb = E.curParent;
                    [E.curTxtLyr destroy];
                    [cb.children removeObjectAtIndex:E.curTxtLyr.c_idx];
                    [cb updateCIdx];
                    incrWidth -= E.curTxtLyr.mainFrame.size.width;
                } else {
                    E.curMode = MODE_INSERT;
                    E.insertCIdx = E.curTxtLyr.c_idx;
                }
            } else {
                E.curMode = MODE_INSERT;
                E.insertCIdx = E.curTxtLyr.c_idx;
            }
        }
        
        EquationTextLayer *tLayer = [[EquationTextLayer alloc] init:op :E.view.inpOrg :E :TEXTLAYER_OP];
        
        if ([E.curParent isMemberOfClass: [EquationBlock class]]) {
            NSLog(@"%s%i~Input Op %@.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, op, tLayer.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((EquationBlock *)E.curParent).guid);
        } else if ([E.curParent isMemberOfClass: [RadicalBlock class]]) {
            NSLog(@"%s%i~Input Op %@.~ID: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, op, tLayer.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((RadicalBlock *)E.curParent).guid);
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        incrWidth += tLayer.frame.size.width;
        
        if(E.curMode == MODE_INPUT) {
            EquationBlock *block = E.curParent;
            
            tLayer.c_idx = block.children.count;
            [block.children addObject:tLayer];
        } else if(E.curMode == MODE_INSERT) {
            EquationBlock *block = E.curParent;
            
            tLayer.c_idx = E.insertCIdx;
            [block.children insertObject:tLayer atIndex:tLayer.c_idx];
            /*Update c_idx*/
            [block updateCIdx];
            E.insertCIdx += 1;
        } else if(E.curMode == MODE_DUMP_ROOT) {
            EquationBlock *block = [[EquationBlock alloc] init:E];
            block.roll = ROLL_ROOT;
            block.parent = nil;
            block.numerFrame = E.root.mainFrame;
            block.numerTopHalf = E.root.mainFrame.size.height / 2.0;
            block.numerBtmHalf = E.root.mainFrame.size.height / 2.0;
            block.mainFrame = block.numerFrame;
            E.root.roll = ROLL_NUMERATOR;
            E.root.parent = block;
            E.root.c_idx = 0;
            [block.children addObject:E.root];
            tLayer.c_idx = 1;
            [block.children addObject:tLayer];
            E.root = block;
            E.curParent = block;
            E.curMode = MODE_INPUT;
        } else if(E.curMode == MODE_DUMP_RADICAL) {
            RadicalBlock *rBlock = E.curParent;
            EquationBlock *eBlock = rBlock.content;
            EquationBlock *newBlock = [[EquationBlock alloc] init:E];
            newBlock.roll = ROLL_ROOT_ROOT;
            newBlock.parent = rBlock;
            newBlock.numerFrame = eBlock.mainFrame;
            newBlock.numerTopHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.numerBtmHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.mainFrame = newBlock.numerFrame;
            eBlock.roll = ROLL_NUMERATOR;
            eBlock.parent = newBlock;
            eBlock.c_idx = 0;
            [newBlock.children addObject:eBlock];
            tLayer.c_idx = 1;
            [newBlock.children addObject:tLayer];
            rBlock.content = newBlock;
            E.curParent = newBlock;
            E.curMode = MODE_INPUT;
        } else if(E.curMode == MODE_DUMP_EXPO) {
            EquationTextLayer *layer = E.curParent;
            EquationBlock *eBlock = layer.expo;
            EquationBlock *newBlock = [[EquationBlock alloc] init:E];
            newBlock.roll = ROLL_EXPO_ROOT;
            newBlock.parent = layer;
            newBlock.numerFrame = eBlock.mainFrame;
            newBlock.numerTopHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.numerBtmHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.mainFrame = newBlock.numerFrame;
            eBlock.roll = ROLL_NUMERATOR;
            eBlock.parent = newBlock;
            eBlock.c_idx = 0;
            [newBlock.children addObject:eBlock];
            tLayer.c_idx = 1;
            [newBlock.children addObject:tLayer];
            layer.expo = newBlock;
            E.curParent = newBlock;
            E.curMode = MODE_INPUT;
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        tLayer.parent = E.curParent;
        [E.view.layer addSublayer:tLayer];
        E.curTxtLyr = nil;
        E.curBlk = tLayer;
        
        //Update frame info of current block */
        //dumpObj(E.root);
        //NSLog(@"%s%i~%f~%@~~~~~~~~~", __FUNCTION__, __LINE__, strSize.width, E.curRoll == ROLL_NUMERATOR?@"N":@"D");
        [(EquationBlock *)E.curParent updateFrameWidth:incrWidth :E.curRoll];
        [E adjustEveryThing:E.root];
        
        /* Move cursor */
        CGFloat cursorOrgX = 0.0;
        CGFloat cursorOrgY = 0.0;
        cursorOrgX = tLayer.frame.origin.x + tLayer.frame.size.width;
        cursorOrgY = tLayer.frame.origin.y;
        E.view.cursor.frame = CGRectMake(cursorOrgX, cursorOrgY, CURSOR_W, E.curFontH);
        E.view.inpOrg = CGPointMake(cursorOrgX, cursorOrgY);
    } else { //Handle "÷"
        
//        if (E.curTxtLyr != nil && E.curTxtLyr.type == TEXTLAYER_EMPTY) {
//            if (E.curTxtLyr.expo != nil) {
//                if ([E.curTxtLyr.expo.children.firstObject isMemberOfClass:[EquationTextLayer class]]) {
//                    EquationTextLayer *l = E.curTxtLyr.expo.children.firstObject;
//                    if (l.type != TEXTLAYER_EMPTY) {
//                        NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
//                        return;
//                    }
//                } else {
//                    NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
//                    return;
//                }
//            }
//        }
        
        if ([E.curParent isMemberOfClass: [EquationBlock class]]) {
            NSLog(@"%s%i~Input Op %@.~~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, op, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((EquationBlock *)E.curParent).guid);
        } else if ([E.curParent isMemberOfClass: [RadicalBlock class]]) {
            NSLog(@"%s%i~Input Op %@.~~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, op, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((RadicalBlock *)E.curParent).guid);
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }
        
        if(E.curMode == MODE_INPUT) {
            EquationBlock *eBlock = E.curParent;
            NSMutableArray *blockChildren = eBlock.children;
            NSEnumerator *enumerator = [blockChildren reverseObjectEnumerator];
            id block;
            CGFloat frameW = 0.0;
            CGFloat frameH = 0.0;
            CGFloat frameX = 0.0;
            CGFloat frameY = 0.0;
            NSUInteger cnt = 0;
            CGFloat newNumerTop = 0.0, newNumerBtm = 0.0;
            if (E.curRoll == ROLL_NUMERATOR) {
                frameY = eBlock.numerFrame.origin.y;
            } else if (E.curRoll == ROLL_DENOMINATOR) {
                frameY = eBlock.denomFrame.origin.y;
            } else
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            
            int parenCnt = 0;
            while (block = [enumerator nextObject]) {
                cnt++;
                if ([block isMemberOfClass: [EquationTextLayer class]]) {
                    EquationTextLayer *layer = block;
                    if (([layer.name isEqual: @"+"] || [layer.name isEqual: @"-"]) && parenCnt == 0)
                        break;
                    
                    if ([layer.name isEqual: @")"])
                        parenCnt++;
                    
                    if ([layer.name isEqual: @"("])
                        parenCnt--;
                    
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
                } else {
                    NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
            }
            
            frameH = newNumerTop + newNumerBtm;
            
            if (block != nil) { // Need a new block
                EquationBlock *newBlock = [[EquationBlock alloc] init:E];
                newBlock.roll = E.curRoll;
                newBlock.parent = eBlock;
                newBlock.numerFrame = CGRectMake(frameX, frameY - E.curFontH, frameW, frameH);
                newBlock.mainFrame = newBlock.numerFrame;
                newBlock.numerTopHalf = newNumerTop;
                newBlock.numerBtmHalf = newNumerBtm;
                /* The value of start had been double checked */
                NSUInteger start = blockChildren.count - cnt + 1;
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
                    } else {
                        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                }
                /* Remove those elements from old block */
                [blockChildren removeObjectsInRange:NSMakeRange(start, cnt-1)];
                /* Add new block into parent block */
                newBlock.c_idx = blockChildren.count;
                [blockChildren addObject: newBlock];
                eBlock = newBlock;
            } else {
                eBlock.numerFrame = CGRectMake(frameX, frameY - E.curFontH, frameW, frameH);
            }
            
            /* Make an empty denominator frame */
            eBlock.denomFrame = CGRectMake(frameX, frameY + frameH - E.curFontH, 0, E.curFontH);
            eBlock.denomTopHalf = E.curFontH / 2.0;
            eBlock.denomBtmHalf = E.curFontH / 2.0;
            eBlock.mainFrame = CGRectUnion(eBlock.numerFrame, eBlock.denomFrame);
//            NSLog(@"%s%i~[%.1f %.1f %.1f %.1f]~[%.1f %.1f %.1f %.1f]~[%.1f %.1f %.1f %.1f]~~~~~~~~", __FUNCTION__, __LINE__, eBlock.mainFrame.origin.x, eBlock.mainFrame.origin.y, eBlock.mainFrame.size.width, eBlock.mainFrame.size.height, eBlock.numerFrame.origin.x, eBlock.numerFrame.origin.y, eBlock.numerFrame.size.width, eBlock.numerFrame.size.height, eBlock.denomFrame.origin.x, eBlock.denomFrame.origin.y, eBlock.denomFrame.size.width, eBlock.denomFrame.size.height);
            
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
                        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else if ([eBlock.parent isMemberOfClass: [EquationTextLayer class]]) {
                    EquationTextLayer *layer = eBlock.parent;
                    [layer updateFrameBaseOnExpo];
                    if ([layer.parent isMemberOfClass:[EquationBlock class]]) {
                        [(EquationBlock *)layer.parent updateFrameHeightS1:layer];
                    } else {
                        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else if ([eBlock.parent isMemberOfClass: [EquationBlock class]]) {
                    [(EquationBlock *)eBlock.parent updateFrameHeightS1:eBlock];
                } else {
                    NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
                
            }
            E.curParent = eBlock;
//            NSLog(@"%s%i~[%.1f %.1f %.1f %.1f]~[%.1f %.1f %.1f %.1f]~[%.1f %.1f %.1f %.1f]~~~~~~~~", __FUNCTION__, __LINE__, eBlock.mainFrame.origin.x, eBlock.mainFrame.origin.y, eBlock.mainFrame.size.width, eBlock.mainFrame.size.height, eBlock.numerFrame.origin.x, eBlock.numerFrame.origin.y, eBlock.numerFrame.size.width, eBlock.numerFrame.size.height, eBlock.denomFrame.origin.x, eBlock.denomFrame.origin.y, eBlock.denomFrame.size.width, eBlock.denomFrame.size.height);
        } else if(E.curMode == MODE_INSERT) {
            if (E.insertCIdx == 0) { // No division while no numerator
                return;
            }
            NSUInteger i = 0, cnt = 0;
            CGFloat frameW = 0.0;
            CGFloat frameH = 0.0;
            CGFloat frameX = 0.0;
            CGFloat frameY = 0.0;
            CGFloat newNumerTop = 0.0, newNumerBtm = 0.0;
            EquationBlock *eBlock = E.curParent;
            EquationBlock *newBlock = [[EquationBlock alloc] init:E];
            newBlock.roll = E.curRoll;
            newBlock.parent = eBlock;
            
            int parenCnt = 0;
            for (int ii = (int)E.insertCIdx - 1; ii >= 0; ii--) {
                i = ii;
                id block = [eBlock.children objectAtIndex:i];
                if ([block isMemberOfClass: [EquationTextLayer class]]) {
                    EquationTextLayer *layer = block;
                    if (([layer.name isEqual: @"+"] || [layer.name isEqual: @"-"]) && parenCnt == 0)
                        break;
                    
                    if ([layer.name isEqual: @")"])
                        parenCnt++;
                    
                    if ([layer.name isEqual: @"("])
                        parenCnt--;
                    
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
                } else {
                    NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
                cnt++;
            }
            
            frameH = newNumerTop + newNumerBtm;
            
            if (i != 0)
                i++;
            
            newBlock.numerFrame = CGRectMake(frameX, frameY - E.curFontH, frameW, frameH);
            newBlock.numerTopHalf = newNumerTop;
            newBlock.numerBtmHalf = newNumerBtm;
            newBlock.denomFrame = CGRectMake(frameX, frameY + frameH - E.curFontH, 0, E.curFontH); //Make an empty denominator frame
            newBlock.denomTopHalf = E.curFontH / 2.0;
            newBlock.denomBtmHalf = E.curFontH / 2.0;
            newBlock.mainFrame = CGRectUnion(newBlock.numerFrame, newBlock.denomFrame);

            [newBlock.children reverse];
            [newBlock updateCIdx];
            /* Remove those elements from old block */
            [eBlock.children removeObjectsInRange:NSMakeRange(i, cnt)];
            /* Add new block into parent block */
            [eBlock.children insertObject:newBlock atIndex:i];
            [eBlock updateCIdx];
            eBlock = newBlock;

            E.curMode = MODE_INPUT;
            
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
                        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else if ([eBlock.parent isMemberOfClass: [EquationTextLayer class]]) {
                    EquationTextLayer *layer = eBlock.parent;
                    [layer updateFrameBaseOnExpo];
                    if ([layer.parent isMemberOfClass:[EquationBlock class]]) {
                        [(EquationBlock *)layer.parent updateFrameHeightS1:layer];
                    } else {
                        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    }
                } else if ([eBlock.parent isMemberOfClass: [EquationBlock class]]) {
                    [(EquationBlock *)eBlock.parent updateFrameHeightS1:eBlock];
                } else {
                    NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
            }
            
            E.curParent = eBlock;
        } else if(E.curMode == MODE_DUMP_ROOT) {
            CGFloat frameW = 0.0;
            CGFloat frameH = 0.0;
            CGFloat frameX = 0.0;
            CGFloat frameY = 0.0;
            EquationBlock *newBlock = [[EquationBlock alloc] init:E];
            newBlock.roll = ROLL_ROOT;
            newBlock.parent = nil;

            frameX = E.root.mainFrame.origin.x;
            frameY = E.root.mainFrame.origin.y - E.curFontH;
            frameW = E.root.mainFrame.size.width;
            frameH = E.root.mainFrame.size.height;

            newBlock.numerFrame = CGRectMake(frameX, frameY, frameW, frameH);
            newBlock.numerTopHalf = frameH / 2.0;
            newBlock.numerBtmHalf = frameH / 2.0;
            newBlock.denomFrame = CGRectMake(frameX, frameY + frameH, 0, E.baseCharHight); //Make an empty denominator frame
            newBlock.denomTopHalf = E.curFontH / 2.0;
            newBlock.denomBtmHalf = E.curFontH / 2.0;
            newBlock.mainFrame = CGRectUnion(newBlock.numerFrame, newBlock.denomFrame);

            E.root.mainFrame = newBlock.numerFrame;
            E.root.c_idx = 0;
            E.root.parent = newBlock;
            E.root.roll = ROLL_NUMERATOR;
            [newBlock.children addObject: E.root];

            E.root = newBlock;
            E.curParent = newBlock;
            E.curMode = MODE_INPUT;
        } else if(E.curMode == MODE_DUMP_RADICAL) {
            CGFloat frameW = 0.0;
            CGFloat frameH = 0.0;
            CGFloat frameX = 0.0;
            CGFloat frameY = 0.0;
            RadicalBlock *rBlock = E.curParent;
            EquationBlock *eBlock = rBlock.content;
            EquationBlock *newBlock = [[EquationBlock alloc] init:E];
            eBlock.roll = ROLL_NUMERATOR;
            newBlock.roll = ROLL_ROOT_ROOT;
            newBlock.parent = rBlock;

            frameX = eBlock.mainFrame.origin.x;
            frameY = eBlock.mainFrame.origin.y - E.curFontH;
            frameW = eBlock.mainFrame.size.width;
            frameH = eBlock.mainFrame.size.height;

            newBlock.numerFrame = CGRectMake(frameX, frameY, frameW, frameH);
            newBlock.numerTopHalf = frameH / 2.0;
            newBlock.numerBtmHalf = frameH / 2.0;
            newBlock.denomFrame = CGRectMake(frameX, frameY + frameH, 0, E.curFontH); //Make an empty denominator frame
            newBlock.denomTopHalf = E.curFontH / 2.0;
            newBlock.denomBtmHalf = E.curFontH / 2.0;
            newBlock.mainFrame = CGRectUnion(newBlock.numerFrame, newBlock.denomFrame);

            eBlock.mainFrame = newBlock.numerFrame;
            eBlock.c_idx = 0;
            eBlock.parent = newBlock;
            [newBlock.children addObject: eBlock];

            rBlock.content = newBlock;
            CGFloat orgW = rBlock.frame.size.width;
            [rBlock updateFrame];
            [rBlock setNeedsDisplay];
            if ([rBlock.parent isMemberOfClass:[EquationBlock class]]) {
                [(EquationBlock *)rBlock.parent updateFrameHeightS1:rBlock];
                [(EquationBlock *)rBlock.parent updateFrameWidth:rBlock.frame.size.width - orgW :rBlock.roll];
            } else {
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            E.curParent = newBlock;
            E.curMode = MODE_INPUT;
        } else if(E.curMode == MODE_DUMP_EXPO) {
            CGFloat frameW = 0.0;
            CGFloat frameH = 0.0;
            CGFloat frameX = 0.0;
            CGFloat frameY = 0.0;
            EquationTextLayer *layer = E.curParent;
            EquationBlock *eBlock = layer.expo;
            EquationBlock *newBlock = [[EquationBlock alloc] init:E];
            eBlock.roll = ROLL_NUMERATOR;
            newBlock.roll = ROLL_EXPO_ROOT;
            newBlock.parent = layer;
            
            frameX = eBlock.mainFrame.origin.x;
            frameY = eBlock.mainFrame.origin.y - E.curFontH;
            frameW = eBlock.mainFrame.size.width;
            frameH = eBlock.mainFrame.size.height;
            
            newBlock.numerFrame = CGRectMake(frameX, frameY, frameW, frameH);
            newBlock.numerTopHalf = frameH / 2.0;
            newBlock.numerBtmHalf = frameH / 2.0;
            newBlock.denomFrame = CGRectMake(frameX, frameY + frameH, 0, E.curFontH); //Make an empty denominator frame
            newBlock.denomTopHalf = E.curFontH / 2.0;
            newBlock.denomBtmHalf = E.curFontH / 2.0;
            newBlock.mainFrame = CGRectUnion(newBlock.numerFrame, newBlock.denomFrame);
            
            eBlock.mainFrame = newBlock.numerFrame;
            eBlock.c_idx = 0;
            eBlock.parent = newBlock;
            [newBlock.children addObject: eBlock];
            
            layer.expo = newBlock;
            [layer updateFrameBaseOnExpo];
            if ([layer.parent isMemberOfClass:[EquationBlock class]]) {
                [(EquationBlock *)layer.parent updateFrameHeightS1:layer];
            } else {
                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            }
            
            E.curParent = newBlock;
            E.curMode = MODE_INPUT;
        } else {
            NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        }

        E.curRoll = ROLL_DENOMINATOR;
        
        EquationBlock *eBlock = E.curParent;
        
        testeb = eBlock;
        
        /* Add a bar into eBlock */
        FractionBarLayer *barLayer = [[FractionBarLayer alloc] init:E];
        NSLog(@"%s%i~Bar id: %i~~~~~~", __FUNCTION__, __LINE__, barLayer.guid);
        barLayer.name = @"/";
        barLayer.hidden = NO;
        barLayer.backgroundColor = [UIColor clearColor].CGColor;
        barLayer.parent = eBlock;
        /*Make bar in the middle of numer and deno*/
        CGRect frame;
        frame.origin.x = eBlock.mainFrame.origin.x;
        frame.size.height = E.curFontH / 2.0;
        frame.origin.y = eBlock.numerFrame.origin.y + eBlock.numerFrame.size.height - (frame.size.height / 2.0);
        frame.size.width = eBlock.mainFrame.size.width;
        
        barLayer.frame = frame;
        barLayer.delegate = self;
        barLayer.c_idx = eBlock.children.count;
        [E.view.layer addSublayer: barLayer];
        [barLayer setNeedsDisplay];
        [eBlock.children addObject: barLayer];
        eBlock.bar = barLayer;
        
        EquationTextLayer *layer = [[EquationTextLayer alloc] init:@"_" :eBlock.denomFrame.origin :E :TEXTLAYER_EMPTY];
        layer.parent = eBlock;
        eBlock.denomFrame = layer.frame;
        layer.c_idx = eBlock.children.count;
        [eBlock.children addObject:layer];
        [E.view.layer addSublayer: layer];
        E.curTxtLyr = layer;
        E.curBlk = layer;
//        NSLog(@"%s%i~[%.1f %.1f %.1f %.1f]~[%.1f %.1f %.1f %.1f]~[%.1f %.1f %.1f %.1f]~~~~~~~~", __FUNCTION__, __LINE__, eBlock.mainFrame.origin.x, eBlock.mainFrame.origin.y, eBlock.mainFrame.size.width, eBlock.mainFrame.size.height, eBlock.numerFrame.origin.x, eBlock.numerFrame.origin.y, eBlock.numerFrame.size.width, eBlock.numerFrame.size.height, eBlock.denomFrame.origin.x, eBlock.denomFrame.origin.y, eBlock.denomFrame.size.width, eBlock.denomFrame.size.height);
        [E adjustEveryThing:E.root];
//        NSLog(@"%s%i~[%.1f %.1f %.1f %.1f]~[%.1f %.1f %.1f %.1f]~[%.1f %.1f %.1f %.1f]~~~~~~~~", __FUNCTION__, __LINE__, eBlock.mainFrame.origin.x, eBlock.mainFrame.origin.y, eBlock.mainFrame.size.width, eBlock.mainFrame.size.height, eBlock.numerFrame.origin.x, eBlock.numerFrame.origin.y, eBlock.numerFrame.size.width, eBlock.numerFrame.size.height, eBlock.denomFrame.origin.x, eBlock.denomFrame.origin.y, eBlock.denomFrame.size.width, eBlock.denomFrame.size.height);
        
        /* Move cursor */
        CGFloat cursorOrgX = 0.0;
        CGFloat cursorOrgY = 0.0;
        cursorOrgX = eBlock.denomFrame.origin.x;
        cursorOrgY = eBlock.denomFrame.origin.y;
        E.view.cursor.frame = CGRectMake(cursorOrgX, cursorOrgY, CURSOR_W, E.curFontH);
        E.view.inpOrg = CGPointMake(cursorOrgX, cursorOrgY);
    }
    
}

- (void)handleRootBtnClick: (int)rootCnt {
    CGFloat incrWidth = 0.0;
    
    if (E.curTxtLyr != nil && E.curTxtLyr.type == TEXTLAYER_EMPTY) {
        if (E.curTxtLyr.expo == nil) {
            EquationBlock *cb = E.curParent;
            [E.curTxtLyr destroy];
            [cb.children removeObjectAtIndex:E.curTxtLyr.c_idx];
            [cb updateCIdx];
            incrWidth -= E.curTxtLyr.mainFrame.size.width;
        } else if ([E.curTxtLyr.expo.children.firstObject isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *l = E.curTxtLyr.expo.children.firstObject;
            if (l.type == TEXTLAYER_EMPTY) {
                EquationBlock *cb = E.curParent;
                [E.curTxtLyr destroy];
                [cb.children removeObjectAtIndex:E.curTxtLyr.c_idx];
                [cb updateCIdx];
                incrWidth -= E.curTxtLyr.mainFrame.size.width;
            } else {
                E.curMode = MODE_INSERT;
                E.insertCIdx = E.curTxtLyr.c_idx;
            }
        } else {
            E.curMode = MODE_INSERT;
            E.insertCIdx = E.curTxtLyr.c_idx;
        }
    }
    
    RadicalBlock *newRBlock = [[RadicalBlock alloc] init:E.view.inpOrg :E :rootCnt];
    NSLog(@"%s%i~Input Root.~ID: %i~Content Id: %i~CIDX: %lu~Mode: %i~Roll: %i~CurBlkId: %i~", __FUNCTION__, __LINE__, newRBlock.guid, newRBlock.content.guid, (unsigned long)E.insertCIdx, E.curMode, E.curRoll, ((EquationBlock *)E.curParent).guid);
    
    incrWidth += newRBlock.frame.size.width;
    
//    if (orgLayer != nil && orgLayer.type == TEXTLAYER_EMPTY) {
//        EquationBlock *cb = E.curBlk;
//        [orgLayer destroy];
//        [cb.children removeObjectAtIndex:orgLayer.c_idx];
//        [cb updateCIdx];
//        incrWidth -= orgLayer.mainFrame.size.width;
//    }
    
    
    if(E.curMode == MODE_INPUT) {
        EquationBlock *eBlock = E.curParent;
        
        newRBlock.c_idx = eBlock.children.count;
        [eBlock.children addObject:newRBlock];
    } else if(E.curMode == MODE_INSERT) {
        EquationBlock *eBlock = E.curParent;

        [eBlock.children insertObject:newRBlock atIndex: E.insertCIdx++];
        
        /*Update c_idx*/
        [eBlock updateCIdx];
    } else if(E.curMode == MODE_DUMP_ROOT) {
        EquationBlock *eBlock = [[EquationBlock alloc] init:E];
        eBlock.roll = ROLL_ROOT;
        eBlock.parent = nil;
        eBlock.numerFrame = E.root.mainFrame;
        eBlock.numerTopHalf = E.root.mainFrame.size.height / 2.0;
        eBlock.numerBtmHalf = E.root.mainFrame.size.height / 2.0;
        eBlock.mainFrame = eBlock.numerFrame;
        E.root.roll = ROLL_NUMERATOR;
        E.root.parent = eBlock;
        E.root.c_idx = 0;
        E.root.roll = E.curRoll;
        [eBlock.children addObject:E.root];
        
        newRBlock.c_idx = 1;
        newRBlock.roll = E.curRoll;
        [eBlock.children addObject: newRBlock];
        E.root = eBlock;
    } else if(E.curMode == MODE_DUMP_RADICAL) {
        RadicalBlock *rBlock = E.curParent;
        EquationBlock *eBlock = rBlock.content;
        EquationBlock *newBlock = [[EquationBlock alloc] init:E];
        newBlock.roll = ROLL_ROOT_ROOT;
        newBlock.parent = rBlock;
        newBlock.numerFrame = eBlock.mainFrame;
        newBlock.numerTopHalf = eBlock.mainFrame.size.height / 2.0;
        newBlock.numerBtmHalf = eBlock.mainFrame.size.height / 2.0;
        newBlock.mainFrame = newBlock.numerFrame;
        eBlock.roll = ROLL_NUMERATOR;
        eBlock.parent = newBlock;
        eBlock.c_idx = 0;
        [newBlock.children addObject:eBlock];

        newRBlock.c_idx = 1;
        [newBlock.children addObject:newRBlock];
        rBlock.content = newBlock;
        E.curParent = newBlock;
    } else if(E.curMode == MODE_DUMP_EXPO) {
        EquationTextLayer *layer = E.curParent;
        EquationBlock *eBlock = layer.expo;
        EquationBlock *newBlock = [[EquationBlock alloc] init:E];
        newBlock.roll = ROLL_EXPO_ROOT;
        newBlock.parent = layer;
        newBlock.numerFrame = eBlock.mainFrame;
        newBlock.numerTopHalf = eBlock.mainFrame.size.height / 2.0;
        newBlock.numerBtmHalf = eBlock.mainFrame.size.height / 2.0;
        newBlock.mainFrame = newBlock.numerFrame;
        eBlock.roll = ROLL_NUMERATOR;
        eBlock.parent = newBlock;
        eBlock.c_idx = 0;
        [newBlock.children addObject:eBlock];

        newRBlock.c_idx = 1;
        [newBlock.children addObject:newRBlock];
        layer.expo = newBlock;
        E.curParent = newBlock;
    } else {
        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    newRBlock.parent = E.curParent;

    newRBlock.delegate = self;
    [E.view.layer addSublayer: newRBlock];
    [newRBlock setNeedsDisplay];
    
    [(EquationBlock *)E.curParent updateFrameWidth:incrWidth :E.curRoll];
    [(EquationBlock *)E.curParent updateFrameHeightS1:newRBlock];
    [E adjustEveryThing:E.root];
    
    E.curMode = MODE_INPUT;
    E.curRoll = ROLL_NUMERATOR;
    E.curParent = newRBlock.content;
    E.view.inpOrg = ((EquationBlock *)E.curParent).mainFrame.origin;
    E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, CURSOR_W, E.curFontH);
    NSLog(@"%s%i~%.1f~~~~~~~~~~", __FUNCTION__, __LINE__, E.view.inpOrg.x);
}

- (void)handlePowBtnClick {
    if (E.curFont == E.superscriptFont || E.curMode == MODE_DUMP_EXPO) { // TODO
        NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        return;
    }
    
    if (E.curTxtLyr == nil) {
        CGPoint pos = E.view.inpOrg;
        CGFloat incrWidth = 0.0;
        
        EquationTextLayer *baseLayer = [[EquationTextLayer alloc] init:@"_" :pos :E :TEXTLAYER_EMPTY];
        baseLayer.parent = E.curParent;
        [E.view.layer addSublayer: baseLayer];
        
        pos.x += baseLayer.frame.size.width;
        pos.y = (pos.y + E.baseCharHight * 0.45) - E.expoCharHight;
        
        E.curFont = E.superscriptFont;
        
        EquationBlock *exp = [[EquationBlock alloc] init:pos :E];
        exp.roll = ROLL_EXPO_ROOT;
        exp.parent = baseLayer;
        baseLayer.expo = exp;
        
        EquationTextLayer *expLayer = [[EquationTextLayer alloc] init:@"_" :pos :E :TEXTLAYER_EMPTY];
        expLayer.parent = exp;
        exp.numerFrame = expLayer.frame;
        exp.mainFrame = expLayer.frame;
        expLayer.roll = ROLL_NUMERATOR;
        expLayer.c_idx = 0;
        [exp.children addObject:expLayer];
        [E.view.layer addSublayer: expLayer];
        [baseLayer updateFrameBaseOnExpo];
        
        incrWidth = baseLayer.mainFrame.size.width;
        
        E.curFont = E.baseFont;
        
        if(E.curMode == MODE_INPUT) {
            EquationBlock *eb = E.curParent;

            baseLayer.c_idx = eb.children.count;
            [eb.children addObject:baseLayer];
        } else if(E.curMode == MODE_INSERT) {
            EquationBlock *eb = E.curParent;

            [eb.children insertObject:baseLayer atIndex: E.insertCIdx++];

            /*Update c_idx*/
            [eb updateCIdx];
        } else if(E.curMode == MODE_DUMP_ROOT) {
            EquationBlock *eBlock = [[EquationBlock alloc] init:E];
            eBlock.roll = ROLL_ROOT;
            eBlock.parent = nil;
            eBlock.numerFrame = E.root.mainFrame;
            eBlock.numerTopHalf = E.root.mainFrame.size.height / 2.0;
            eBlock.numerBtmHalf = E.root.mainFrame.size.height / 2.0;
            eBlock.mainFrame = eBlock.numerFrame;
            E.root.roll = ROLL_NUMERATOR;
            E.root.parent = eBlock;
            E.root.c_idx = 0;
            E.root.roll = E.curRoll;
            [eBlock.children addObject:E.root];
            
            baseLayer.c_idx = 1;
            [eBlock.children addObject: baseLayer];
            E.root = eBlock;
            E.curMode = MODE_INPUT;
        } else if(E.curMode == MODE_DUMP_RADICAL) {
            RadicalBlock *rBlock = E.curParent;
            EquationBlock *eBlock = rBlock.content;
            EquationBlock *newBlock = [[EquationBlock alloc] init:E];
            newBlock.roll = ROLL_ROOT_ROOT;
            newBlock.parent = rBlock;
            newBlock.numerFrame = eBlock.mainFrame;
            newBlock.numerTopHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.numerBtmHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.mainFrame = newBlock.numerFrame;
            eBlock.roll = ROLL_NUMERATOR;
            eBlock.parent = newBlock;
            eBlock.c_idx = 0;
            [newBlock.children addObject:eBlock];

            baseLayer.c_idx = 1;
            [newBlock.children addObject:baseLayer];
            rBlock.content = newBlock;
            E.curParent = newBlock;
            E.curMode = MODE_INPUT;
        } else
            NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        
        [(EquationBlock *)E.curParent updateFrameWidth:incrWidth :E.curRoll];
        [(EquationBlock *)E.curParent updateFrameHeightS1:baseLayer];
        [E adjustEveryThing:E.root];
        
        E.curTxtLyr = baseLayer;
        E.curBlk = baseLayer;
        E.view.inpOrg = baseLayer.frame.origin;
        E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, CURSOR_W, E.curFontH);
    } else {
        E.curFont = E.superscriptFont;
        
        if (E.curTxtLyr.expo == nil) {
            CGFloat orgW = E.curTxtLyr.mainFrame.size.width;
            CGFloat x = E.curTxtLyr.frame.origin.x + orgW;
            
            CGFloat y = (E.view.inpOrg.y + E.baseCharHight * 0.45) - E.expoCharHight;
            E.view.inpOrg = CGPointMake(x, y);
            E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, CURSOR_W, E.expoCharHight);
            
            EquationBlock *eBlock = [[EquationBlock alloc] init:E.view.inpOrg :E];
            eBlock.roll = ROLL_EXPO_ROOT;
            eBlock.parent = E.curTxtLyr;
            E.curTxtLyr.expo = eBlock;
            
            EquationTextLayer *layer = [[EquationTextLayer alloc] init:@"_" :E.view.inpOrg :E :TEXTLAYER_EMPTY];
            layer.parent = eBlock;
            eBlock.numerFrame = layer.frame;
            eBlock.mainFrame = layer.frame;
            layer.roll = ROLL_NUMERATOR;
            layer.c_idx = 0;
            [eBlock.children addObject:layer];
            [E.view.layer addSublayer: layer];
            [E.curTxtLyr updateFrameBaseOnExpo];
            
            NSLog(@"[%s%i]~%f~%f~~~~~~~~~", __FUNCTION__, __LINE__, E.curTxtLyr.mainFrame.size.width, E.root.numerFrame.size.width);
            CGFloat inc = E.curTxtLyr.mainFrame.size.width - orgW;
            [(EquationBlock *)E.curParent updateFrameWidth:inc :E.curRoll];
            [(EquationBlock *)E.curParent updateFrameHeightS1:E.curTxtLyr];
            [E adjustEveryThing:E.root];
            
            E.curTxtLyr = layer;
            E.curBlk = layer;
            E.curParent = eBlock;
            E.curRoll = ROLL_NUMERATOR;
            E.curMode = MODE_INPUT;
        } else {
            EquationBlock *exp = E.curTxtLyr.expo;
            id lastObj = exp.children.lastObject;
            if ([lastObj isMemberOfClass:[EquationTextLayer class]]) {
                EquationTextLayer *layer = lastObj;
                CGFloat tmp;
                if (layer.type == TEXTLAYER_EMPTY) {
                    E.view.inpOrg = layer.frame.origin;
                    tmp = E.expoCharHight;
                    E.curTxtLyr = layer;
                } else {
                    CGFloat x = layer.mainFrame.origin.x + layer.mainFrame.size.width;
                    CGFloat y = layer.mainFrame.origin.y;
                    E.view.inpOrg = CGPointMake(x, y);
                    tmp = layer.mainFrame.size.height;
                    
                    if (layer.type == TEXTLAYER_NUM) {
                        E.curTxtLyr = layer;
                    } else {
                        E.curTxtLyr = nil;
                        
                    }
                }
                E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, CURSOR_W, tmp);
                E.curBlk = layer;
                E.curParent = exp;
                E.curRoll = layer.roll;
                E.curMode = MODE_INPUT;
            } else if ([lastObj isMemberOfClass:[EquationBlock class]]) {
                EquationBlock *eb = lastObj;
                CGFloat x = eb.mainFrame.origin.x + eb.mainFrame.size.width;
                CGFloat y = eb.mainFrame.origin.y + eb.mainFrame.size.height / 2.0 - E.curFontH / 2.0;
                E.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = eb.mainFrame.size.height;
                E.view.cursor.frame = CGRectMake(eb.mainFrame.origin.x, eb.mainFrame.origin.y, CURSOR_W, tmp);
                E.curTxtLyr = nil;
                E.curBlk = eb;
                E.curParent = exp;
                E.curRoll = eb.roll;
                E.curMode = MODE_INPUT;
            } else if ([lastObj isMemberOfClass:[RadicalBlock class]]) {
                RadicalBlock *rb = lastObj;
                CGFloat x = rb.frame.origin.x + rb.frame.size.width;
                CGFloat y = rb.frame.origin.y + rb.frame.size.height / 2.0 - E.curFontH / 2.0;
                E.view.inpOrg = CGPointMake(x, y);
                CGFloat tmp = rb.frame.size.height;
                E.view.cursor.frame = CGRectMake(rb.frame.origin.x, rb.frame.origin.y, CURSOR_W, tmp);
                E.curTxtLyr = nil;
                E.curBlk = rb;
                E.curParent = exp;
                E.curRoll = rb.roll;
                E.curMode = MODE_INPUT;
            }
        }
        
    }
}

- (void)handleParenthBtnClick : (NSString *)parenth {
    CGFloat incrWidth = 0.0;
    
    if (E.curTxtLyr != nil && E.curTxtLyr.type == TEXTLAYER_EMPTY) {
        if (E.curTxtLyr.expo == nil) {
            EquationBlock *cb = E.curParent;
            [E.curTxtLyr destroy];
            [cb.children removeObjectAtIndex:E.curTxtLyr.c_idx];
            [cb updateCIdx];
            incrWidth -= E.curTxtLyr.mainFrame.size.width;
        } else if ([E.curTxtLyr.expo.children.firstObject isMemberOfClass:[EquationTextLayer class]]) {
            EquationTextLayer *l = E.curTxtLyr.expo.children.firstObject;
            if (l.type == TEXTLAYER_EMPTY) {
                EquationBlock *cb = E.curParent;
                [E.curTxtLyr destroy];
                [cb.children removeObjectAtIndex:E.curTxtLyr.c_idx];
                [cb updateCIdx];
                incrWidth -= E.curTxtLyr.mainFrame.size.width;
            } else {
                E.curMode = MODE_INSERT;
                E.insertCIdx = E.curTxtLyr.c_idx;
            }
        } else {
            E.curMode = MODE_INSERT;
            E.insertCIdx = E.curTxtLyr.c_idx;
        }
    }

    EquationTextLayer *tLayer = [[EquationTextLayer alloc] init:parenth :E.view.inpOrg :E :TEXTLAYER_PARENTH];
    incrWidth += tLayer.frame.size.width;
    if(E.curMode == MODE_INPUT) {
        EquationBlock *block = E.curParent;
        
        tLayer.c_idx = block.children.count;
        [block.children addObject:tLayer];
    } else if(E.curMode == MODE_INSERT) {
        //NSLog(@"%s%i~~~%lu~~~~~~~~", __FUNCTION__, __LINE__, (unsigned long)E.insertCIdx);
        EquationBlock *block = E.curParent;
        
        tLayer.c_idx = E.insertCIdx;
        [block.children insertObject:tLayer atIndex:tLayer.c_idx];
        /*Update c_idx*/
        [block updateCIdx];
        E.insertCIdx += 1;
    } else if(E.curMode == MODE_DUMP_ROOT) {
        if ([parenth isEqual:@"("]) {
            EquationBlock *block = [[EquationBlock alloc] init:E];
            block.roll = ROLL_ROOT;
            block.parent = nil;
            block.numerFrame = E.root.mainFrame;
            block.numerTopHalf = E.root.mainFrame.size.height / 2.0;
            block.numerBtmHalf = E.root.mainFrame.size.height / 2.0;
            block.mainFrame = block.numerFrame;
            E.root.roll = ROLL_NUMERATOR;
            E.root.parent = block;
            E.root.c_idx = 0;
            [block.children addObject:E.root];

            tLayer.c_idx = 1;
            [block.children addObject:tLayer];
            E.root = block;
            E.curParent = block;
            E.curMode = MODE_INPUT;
        } else {
            NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return;
        }
        
    } else if(E.curMode == MODE_DUMP_RADICAL) {
        if ([parenth isEqual:@"("]) {
            RadicalBlock *rBlock = E.curParent;
            EquationBlock *eBlock = rBlock.content;
            EquationBlock *newBlock = [[EquationBlock alloc] init:E];
            newBlock.roll = ROLL_ROOT_ROOT;
            newBlock.parent = rBlock;
            newBlock.numerFrame = eBlock.mainFrame;
            newBlock.numerTopHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.numerBtmHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.mainFrame = newBlock.numerFrame;
            eBlock.roll = ROLL_NUMERATOR;
            eBlock.parent = newBlock;
            eBlock.c_idx = 0;
            [newBlock.children addObject:eBlock];

            tLayer.c_idx = 1;
            [newBlock.children addObject:tLayer];
            rBlock.content = newBlock;
            E.curParent = newBlock;
            E.curMode = MODE_INPUT;
        } else {
            NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return;
        }
    } else if(E.curMode == MODE_DUMP_EXPO) {
        if ([parenth isEqual:@"("]) {
            EquationTextLayer *layer = E.curParent;
            EquationBlock *eBlock = layer.expo;
            EquationBlock *newBlock = [[EquationBlock alloc] init:E];
            newBlock.roll = ROLL_EXPO_ROOT;
            newBlock.parent = layer;
            newBlock.numerFrame = eBlock.mainFrame;
            newBlock.numerTopHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.numerBtmHalf = eBlock.mainFrame.size.height / 2.0;
            newBlock.mainFrame = newBlock.numerFrame;
            eBlock.roll = ROLL_NUMERATOR;
            eBlock.parent = newBlock;
            eBlock.c_idx = 0;
            [newBlock.children addObject:eBlock];

            tLayer.c_idx = 1;
            [newBlock.children addObject:tLayer];
            layer.expo = newBlock;
            E.curParent = newBlock;
            E.curMode = MODE_INPUT;
        } else {
            NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return;
        }
    } else {
        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        return;
    }
    
    tLayer.parent = E.curParent;
    [E.view.layer addSublayer:tLayer];
    
    /* Update frame info of current block */
    [(EquationBlock *)E.curParent updateFrameWidth:incrWidth :E.curRoll];
    [E adjustEveryThing:E.root];
    
    /* Move cursor */
    CGFloat cursorOrgX = tLayer.frame.origin.x + tLayer.frame.size.width;
    CGFloat cursorOrgY = tLayer.frame.origin.y;
    
    E.view.cursor.frame = CGRectMake(cursorOrgX, cursorOrgY, CURSOR_W, E.curFontH);
    E.view.inpOrg = CGPointMake(cursorOrgX, cursorOrgY);
    
    E.curBlk = tLayer;
    E.curTxtLyr = nil;
}

- (void)handleDelBtnClick {
    CGFloat incrWidth = 0.0;
    if ([E.curBlk isMemberOfClass:[EquationBlock class]]) {
        EquationBlock *eb = E.curBlk;
        if (E.insertCIdx == eb.c_idx) {
            id pre = getPrevBlk(E, eb);
            if (eb.c_idx == 0) {
                if (pre != nil) {
                    if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *layer = pre;
                        if (layer.is_base_expo == eb.is_base_expo) {
                            (void)locaLastTxtLyr(E, pre);
                        } else { //Switch from expo to base in a same text layer
                            E.curTxtLyr = layer;
                            E.curBlk = layer;
                            E.curParent = layer.parent;
                            E.curRoll = layer.roll;
                            E.curMode = MODE_INSERT;
                            E.insertCIdx = layer.c_idx + 1;
                            E.txtInsIdx = layer.strLenTbl.count - 1;

                            if (layer.is_base_expo == IS_BASE) {
                                E.curFont = E.baseFont;
                            } else if (layer.is_base_expo == IS_EXPO) {
                                E.curFont = E.superscriptFont;
                            } else {
                                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                            }
                            
                            E.view.inpOrg = CGPointMake(layer.frame.origin.x + layer.frame.size.width, layer.frame.origin.y);
                            E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, CURSOR_W, E.curFontH);
                        }
                    } else {
                        (void)locaLastTxtLyr(E, pre);
                    }
                } else {
                    return;
                }
            } else {
                if (pre != nil) {
                    if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = pre;
                        if (l.expo != nil) {
                            (void)locaLastTxtLyr(E, l);
                        } else {
                            if (l.strLenTbl.count == 2 || l.strLenTbl.count == 1) {
                                [E removeElement:l];
                            } else {
                                [l delNumCharAt:l.strLenTbl.count - 1];
                            }
                        }
                    } else {
                        (void)locaLastTxtLyr(E, pre);
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    return;
                }
            }
        } else if (E.insertCIdx == eb.c_idx + 1) {
            (void)locaLastTxtLyr(E, eb);
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return;
        }
    } else if ([E.curBlk isMemberOfClass:[RadicalBlock class]]) {
        RadicalBlock *rb = E.curBlk;
        if (E.insertCIdx == rb.c_idx) {
            id pre = getPrevBlk(E, rb);
            if (rb.c_idx == 0) {
                if (pre != nil) {
                    if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *layer = pre;
                        if (layer.is_base_expo == rb.is_base_expo) {
                            (void)locaLastTxtLyr(E, pre);
                        } else { //Switch from expo to base in a same text layer
                            E.curTxtLyr = layer;
                            E.curBlk = layer;
                            E.curParent = layer.parent;
                            E.curRoll = layer.roll;
                            E.curMode = MODE_INSERT;
                            E.insertCIdx = layer.c_idx + 1;
                            E.txtInsIdx = layer.strLenTbl.count - 1;

                            if (layer.is_base_expo == IS_BASE) {
                                E.curFont = E.baseFont;
                            } else if (layer.is_base_expo == IS_EXPO) {
                                E.curFont = E.superscriptFont;
                            } else {
                                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                            }
                            
                            E.view.inpOrg = CGPointMake(layer.frame.origin.x + layer.frame.size.width, layer.frame.origin.y);
                            E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, CURSOR_W, E.curFontH);
                        }
                    } else {
                        (void)locaLastTxtLyr(E, pre);
                    }
                } else {
                    return;
                }
            } else {
                if (pre != nil) {
                    if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = pre;
                        if (l.expo != nil) {
                            (void)locaLastTxtLyr(E, l);
                        } else {
                            if (l.strLenTbl.count == 2 || l.strLenTbl.count == 1) {
                                [E removeElement:l];
                            } else {
                                [l delNumCharAt:l.strLenTbl.count - 1];
                            }
                        }
                    } else {
                        (void)locaLastTxtLyr(E, pre);
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    return;
                }
            }
        } else if (E.insertCIdx == rb.c_idx + 1) {
            (void)locaLastTxtLyr(E, rb);
        } else {
            NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
            return;
        }
    } else if ([E.curBlk isMemberOfClass:[FractionBarLayer class]]) {
        NSLog(@"[%s%i]~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
        return;
    } else if ([E.curBlk isMemberOfClass:[EquationTextLayer class]]) {
        EquationTextLayer *curLayer = E.curBlk;
        if (E.insertCIdx == curLayer.c_idx) {
            id pre = getPrevBlk(E, curLayer);
            if (curLayer.c_idx == 0) {
                if (pre != nil) {
                    if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *layer = pre;
                        if (layer.is_base_expo == curLayer.is_base_expo) {
                            (void)locaLastTxtLyr(E, pre);
                        } else { //Switch from expo to base in a same text layer
                            E.curTxtLyr = layer;
                            E.curBlk = layer;
                            E.curParent = layer.parent;
                            E.curRoll = layer.roll;
                            E.curMode = MODE_INSERT;
                            E.insertCIdx = layer.c_idx + 1;
                            E.txtInsIdx = layer.strLenTbl.count - 1;

                            if (layer.is_base_expo == IS_BASE) {
                                E.curFont = E.baseFont;
                            } else if (layer.is_base_expo == IS_EXPO) {
                                E.curFont = E.superscriptFont;
                            } else {
                                NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                            }
                            
                            E.view.inpOrg = CGPointMake(layer.frame.origin.x + layer.frame.size.width, layer.frame.origin.y);
                            E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, CURSOR_W, E.curFontH);
                        }
                    } else {
                        (void)locaLastTxtLyr(E, pre);
                    }
                } else {
                    return;
                }
            } else {
                if (pre != nil) {
                    if ([pre isMemberOfClass:[EquationTextLayer class]]) {
                        EquationTextLayer *l = pre;
                        if (l.expo != nil) {
                            (void)locaLastTxtLyr(E, l);
                        } else {
                            if (l.strLenTbl.count == 2 || l.strLenTbl.count == 1) {
                                [E removeElement:l];
                            } else {
                                [l delNumCharAt:l.strLenTbl.count - 1];
                            }
                        }
                    } else {
                        (void)locaLastTxtLyr(E, pre);
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                    return;
                }
            }
        } else if (E.insertCIdx == curLayer.c_idx + 1) {
            if (layer.expo != nil && E.curTxtLyr == nil) {
                id blk = layer.expo.children.lastObject;
                (void)locaLastTxtLyr(E, blk);
            } else {
                if (layer.type == TEXTLAYER_NUM) {
                    NSMutableAttributedString *orgStr = [[NSMutableAttributedString alloc] initWithAttributedString:layer.string];
                    if (orgStr.length == 1 && E.txtInsIdx == 1) {
                        if (layer.expo != nil) {
                            CGFloat orgWidth = [orgStr size].width;
                            [orgStr replaceCharactersInRange:NSMakeRange(0, 1) withString:@"_"];
                            [orgStr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0,1)];
                            CGFloat newWidth = [orgStr size].width;
                            incrWidth = newWidth - orgWidth;
                            
                            CGRect frame = layer.frame;
                            frame.size.width = [orgStr size].width;
                            layer.frame = frame;
                            layer.string = orgStr;
                            [layer updateFrameBaseOnBase];
                            
                            [(EquationBlock *)E.curParent updateFrameWidth:incrWidth :layer.roll];
                            [E adjustEveryThing:E.root];
                            
                            E.view.inpOrg = CGPointMake(layer.frame.origin.x, layer.frame.origin.y);
                            E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, CURSOR_W, E.curFontH);
                            
                            layer.type = TEXTLAYER_EMPTY;
                        } else {
                            [E removeElement:layer];
                        }
                    } else if (E.txtInsIdx == 0) {
                        (void)findPrevTxtLayer(E, layer);
                    } else {
                        CGFloat orgW = layer.mainFrame.size.width;
                        CGFloat offset = [layer delNumCharAt:E.txtInsIdx--];
                        incrWidth += layer.mainFrame.size.width - orgW;
                        [(EquationBlock *)E.curParent updateFrameWidth:incrWidth :E.curRoll];
                        [E adjustEveryThing:E.root];
                        E.view.inpOrg = CGPointMake(layer.frame.origin.x + offset, layer.frame.origin.y);
                        E.view.cursor.frame = CGRectMake(E.view.inpOrg.x, E.view.inpOrg.y, CURSOR_W, E.curFontH);
                    }
                } else if (layer.type == TEXTLAYER_OP || layer.type == TEXTLAYER_PARENTH) {
                    if (E.txtInsIdx == 0) {
                        (void)findPrevTxtLayer(E, layer);
                    } else {
                        [E removeElement:layer];
                    }
                } else if (layer.type == TEXTLAYER_EMPTY) {
                    if ([layer isExpoEmpty]) {
                        [E removeElement:layer];
                    } else {
                        (void)findPrevTxtLayer(E, layer);
                    }
                } else {
                    NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                }
            } else {
                NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
                return;
            }
    }
    } else {
        NSLog(@"%s%i>~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
    }
}

-(void)delBlock:(NSTimer *)timer{
    NSLog(@"%s%i>~~~~~~~~~~~", __FUNCTION__, __LINE__);
    [self handleDelBtnClick];
}

-(void)btnDelLongPress:(UILongPressGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        NSLog(@"%s%i>~~~~~~~~~~~", __FUNCTION__, __LINE__);
        delBtnLongPressTmr = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(delBlock:) userInfo:nil repeats:YES];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"%s%i>~~~~~~~~~~~", __FUNCTION__, __LINE__);
        if ([delBtnLongPressTmr isValid] == YES) {
            [delBtnLongPressTmr invalidate];
            delBtnLongPressTmr = nil;
        }
    }
}

-(void)btnClicked: (UIButton *)btn {
    
    if([[btn currentTitle]  isEqual: @"DUMP"]) {
        [E dumpEverything:E.root];
        NSLog(@"InputX: %.1f InputY: %.1f~~~~~~~~~~~", E.view.inpOrg.x, E.view.inpOrg.y);
    } else if([[btn currentTitle]  isEqual: @"DEBUG"]) {
        drawFrame(self, E.view, E.root);
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
        [self handleParenthBtnClick:@"("];
    } else if([[btn currentTitle]  isEqual: @")"]) {
        [self handleParenthBtnClick:@")"];
    } else if([[btn currentTitle]  isEqual: @"<-"]) {
        [self handleDelBtnClick];
    } else if([[btn currentTitle]  isEqual: @"·"]) {
        NSLog(@"[%s%i]~~~~~~~~~~~", __FUNCTION__, __LINE__);
        gCurEqIdx = 0;
        E = [gEquationList objectAtIndex:gCurEqIdx];
        [E.view.cursor removeAllAnimations];
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"hidden"];
        anim.fromValue = [NSNumber numberWithBool:YES];
        anim.toValue = [NSNumber numberWithBool:NO];
        anim.duration = 0.5;
        anim.autoreverses = YES;
        anim.repeatCount = HUGE_VALF;
        [E.view.cursor addAnimation:anim forKey:nil];
        E.view.frame = CGRectOffset(E.view.frame, scnWidth, 0.0);
        [dspConView addSubview:E.view];
        //orgView.center = CGPointMake(0., CGRectGetMidY(self.view.bounds));
        
        // Animate!
        [UIView animateWithDuration:.5 animations:^{
            
            [E.view setEasingFunction:CreateCAMediaTimingFunction(0.175, 0.885, 0.52, 1.25) forKeyPath:@"center"];
            
            E.view.frame = CGRectMake(0, 0, scnWidth, (scnHeight / 2) - statusBarHeight);
            
        } completion:^(BOOL finished) {
            
            [E.view removeEasingFunctionForKeyPath:@"center"];
            
        }];
//        gCurEqIdx = 0;
//        E = [gEquationList objectAtIndex:gCurEqIdx];
//        [E.view.cursor removeAllAnimations];
//        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"hidden"];
//        anim.fromValue = [NSNumber numberWithBool:YES];
//        anim.toValue = [NSNumber numberWithBool:NO];
//        anim.duration = 0.5;
//        anim.autoreverses = YES;
//        anim.repeatCount = HUGE_VALF;
//        [E.view.cursor addAnimation:anim forKey:nil];
//        [dspConView addSubview:E.view];
    } else if([[btn currentTitle]  isEqual: @"%"]) {
        NSLog(@"[%s%i]~%@~~~~~~~~~~", __FUNCTION__, __LINE__, testeb);
    } else
        NSLog(@"%s%i~~ERR~~~~~~~~~", __FUNCTION__, __LINE__);
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
        //NSLog(@"%s%i~%.2f~~~~~~~~~~", __FUNCTION__, __LINE__, bar.frame.size.width);
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
        //NSLog(@"%s%i~%.2f~~~~~~~~~~", __FUNCTION__, __LINE__, bar.frame.size.width);
    } else if ([layer.name isEqual: @"drawframe"]) {
        CGContextSetRGBStrokeColor(ctx, 0, 0, 0.7, 1);
        CGContextSetLineWidth(ctx, 0.5);
        
        CGPoint points[] = {CGPointMake(0.0, 0.0), CGPointMake(layer.frame.size.width - 0.0, 0.0),
            CGPointMake(layer.frame.size.width - 0.5, 0.0), CGPointMake(layer.frame.size.width - 0.5, layer.frame.size.height),
            CGPointMake(layer.frame.size.width - 0.5, layer.frame.size.height - 0.5), CGPointMake(0.5, layer.frame.size.height - 0.5),
            CGPointMake(0.5, layer.frame.size.height), CGPointMake(0.5, 0.0)};
        CGContextStrokeLineSegments(ctx, points, 8);
    } else
        NSLog(@"[%s%i]~~ERR~%@~~~~~~~~", __FUNCTION__, __LINE__, layer.name);
}

@end
