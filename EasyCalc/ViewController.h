//
//  ViewController.h
//  EasyCalc
//
//  Created by LiBoli on 15/11/20.
//  Copyright © 2015年 LiBoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DisplayView.h"
#import "MGSwipeTableCell.h"

@class Equation;
@class EquationBlock;
@class EquationTextLayer;
@class RadicalBlock;
@class QBPopupMenu;
@class SaveTemplateDialog;

@interface ViewController : UIViewController <UIGestureRecognizerDelegate, MGSwipeTableCellDelegate, UITableViewDataSource, UITableViewDelegate>
@property UIView *dspConView;
@property UIView *mainKbView;
@property UIView *secondKbView;
@property UIView *kbConView;
@property CALayer *borderLayer;
@property CGFloat scnWidth;
@property CGFloat scnHeight;
@property CGFloat statusBarHeight;
@property (weak) EquationBlock *testeb;
@property NSTimer *delBtnLongPressTmr;
@property (nonatomic, strong) QBPopupMenu *popMenu;
@property SaveTemplateDialog *saveTempDlg;


-(void)handleTap: (UITapGestureRecognizer *)gesture;
-(void)handleDspViewSwipeRight: (UISwipeGestureRecognizer *)gesture;
-(void)handleDspViewSwipeLeft: (UISwipeGestureRecognizer *)gesture;
-(void)btnClicked: (UIButton *)btn;
-(void)handleLongPress: (UILongPressGestureRecognizer *)gesture;
-(void)saveTemplateOkClicked: (UIButton *)btn;
-(void)saveTemplateCancelClicked: (UIButton *)btn;
@end
