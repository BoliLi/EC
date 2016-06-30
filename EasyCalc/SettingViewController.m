//
//  SettingViewController.m
//  EasyCalc
//
//  Created by LiBoli on 16/5/30.
//  Copyright © 2016年 LiBoli. All rights reserved.
//

#import "Global.h"
#import "CalcBoard.h"
#import "SettingViewController.h"
#import "UIView+Easing.h"
#import "FormatAndSizeViewController.h"
#import "Equation.h"
#import "EquationBlock.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

-(void)segmentAction:(UISegmentedControl *)Seg{
    NSInteger Index = Seg.selectedSegmentIndex;
    NSLog(@"%s%i>~%i~~~~~~~~~~", __FUNCTION__, __LINE__, Index);
    switch (Index) {
        case 0:
            
            break;
            
        default:
            break;
    }
}

-(void)soundsSetting:(UISwitch *)sw{
    NSLog(@"section:%i,switch:%i",sw.tag, sw.on);
}

-(void)handsSetting:(UISwitch *)sw{
    NSLog(@"section:%i,switch:%i",sw.tag, sw.on);
}

-(void)selectRightAction:(id)sender
{
    CATransition *transition = [CATransition animation];
    transition.duration = .4f;
    transition.timingFunction = easeInOutQuad;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromBottom;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController popViewControllerAnimated:NO];
    [gCurCB.view refreshCursorAnim];
    
    if (gCurCB.curEq.mainFontLevel != gSettingMainFontLevel) {
        EquationBlock *rootB = gCurCB.curEq.root;
        [rootB updateSize:0];
        rootB.mainFrame = CGRectMake(gCurCB.downLeftBasePoint.x, gCurCB.downLeftBasePoint.y - rootB.mainFrame.size.height, rootB.mainFrame.size.width, rootB.mainFrame.size.height);
        [rootB adjustElementPosition];
        [gCurCB.curBlk updateCalcBoardInfo];
        [gCurCB adjustEquationHistoryPostion];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.navigationController setNavigationBarHidden:NO];
    [self setTitle:@"Setting"];
//    self.navigationController.navigationItem.title = @"Setting";
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(selectRightAction:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [self.navigationItem setHidesBackButton:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //warning Incomplete implementation, return the number of sections
    
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    } else if (section == 1) {
        return 1;
    } else if (section == 2) {
        return 2;
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s%i>~~生成单元格(组：%i,行%i)~~~~~~~~~", __FUNCTION__, __LINE__, indexPath.section,indexPath.row);
    
    //由于此方法调用十分频繁，cell的标示声明成静态变量有利于性能优化
    static NSString *cellIdentifier=@"UITableViewCellIdentifierKey1";
    //首先根据标识去缓存池取
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    //如果缓存池没有到则重新创建并放到缓存池中
    if(!cell){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        NSLog(@"%s%i>~~~~~~~~~~~", __FUNCTION__, __LINE__);
    }
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Format and Size";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 1:
            {
                cell.textLabel.text = @"Angles";
                NSArray *arr = [[NSArray alloc]initWithObjects:@"Radians", @"Degrees", nil];
                UISegmentedControl *segment = [[UISegmentedControl alloc]initWithItems:arr];
                segment.selectedSegmentIndex = 0;
                [segment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = segment;
            }
                break;
            case 2:
            {
                cell.textLabel.text = @"Sounds";
                UISwitch *sw=[[UISwitch alloc]init];
                sw.on = YES;
                [sw addTarget:self action:@selector(soundsSetting:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView=sw;
            }
                break;
            case 3:
            {
                cell.textLabel.text = @"Left Handed";
                UISwitch *sw=[[UISwitch alloc]init];
                sw.on = NO;
                [sw addTarget:self action:@selector(handsSetting:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView=sw;
            }
                break;
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Reset";
                break;
            default:
                break;
        }
    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"What's new";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 1:
                cell.textLabel.text = @"About";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            default:
                break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        FormatAndSizeViewController *vc = [[FormatAndSizeViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
