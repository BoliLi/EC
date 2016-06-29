//
//  FormatAndSizeViewController.m
//  EasyCalc
//
//  Created by LiBoli on 16/6/5.
//  Copyright © 2016年 LiBoli. All rights reserved.
//

#import "FormatAndSizeViewController.h"
#import "Global.h"
#import <ChameleonFramework/Chameleon.h>
#import "TableViewCellSlider.h"

@interface FormatAndSizeViewController ()
@property UILabel *label;
@end

@implementation FormatAndSizeViewController
@synthesize label;

- (void)updateLabel {
    NSNumber *sample = [NSNumber numberWithDouble:1234567890.12345];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.maximumFractionDigits = gSettingMaxFractionDigits;
    if ([sample compare:gSettingMaxDecimal] == NSOrderedDescending) {
        formatter.numberStyle = NSNumberFormatterScientificStyle;
    } else {
        if (gSettingThousandSeperator) {
            formatter.numberStyle = NSNumberFormatterDecimalStyle;
        } else {
            formatter.numberStyle = NSNumberFormatterNoStyle;
        }
    }
    
    UIFont *font = getFont(gSettingMainFontLevel, 0);
    NSMutableAttributedString *attStr;
    CGSize newStrSize = CGSizeZero;
    attStr = [[NSMutableAttributedString alloc] initWithString:[formatter stringFromNumber:sample]];
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)ctFont range:NSMakeRange(0, attStr.length)];
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor flatWatermelonColor] range:NSMakeRange(0, attStr.length)];
    CFRelease(ctFont);
    newStrSize = [attStr size];
    label.textAlignment = NSTextAlignmentCenter;
    label.attributedText = attStr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 1;
    } else if (section == 2) {
        return 2;
    } else if (section == 3) {
        return 1;
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
            {
                label = [[UILabel alloc] init];
                label.frame = cell.contentView.frame;
                [self updateLabel];
                [cell.contentView addSubview:label];
            }
                break;
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
            {
                TableViewCellSlider *sliderCell = [[TableViewCellSlider alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"TableViewCellSlider" title:@"Text Size"];
                sliderCell.slider.minimumValue = 0.0;
                sliderCell.slider.maximumValue = 4.0;
                sliderCell.slider.value = gSettingMainFontLevel;
                
                [sliderCell.slider addTarget:self action:@selector(sliderFontSizeValueChanged:) forControlEvents:UIControlEventValueChanged];
                cell = sliderCell;
            }
                break;
            default:
                break;
        }
    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
            {
                cell.textLabel.text = @"Thousand Separators";
                UISwitch *sw=[[UISwitch alloc]init];
                sw.on = gSettingThousandSeperator;
                [sw addTarget:self action:@selector(thousandSeparatorsSetting:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView=sw;
            }
                break;
            case 1:
            {
                TableViewCellSlider *sliderCell = [[TableViewCellSlider alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"TableViewCellSlider" title:@"Max Fraction Digits"];
                sliderCell.slider.minimumValue = 0.0;
                sliderCell.slider.maximumValue = 10.0;
                sliderCell.slider.value = gSettingMaxFractionDigits;
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                [formatter setNumberStyle:NSNumberFormatterNoStyle];
                [sliderCell.slider setNumberFormatter:formatter];
                [sliderCell.slider addTarget:self action:@selector(sliderMaxFracDigiValueChanged:) forControlEvents:UIControlEventValueChanged];
                cell = sliderCell;
            }
                break;
            default:
                break;
        }
    } else if (indexPath.section == 3) {
        switch (indexPath.row) {
            case 0:
            {
                TableViewCellSlider *sliderCell = [[TableViewCellSlider alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"TableViewCellSlider" title:@"Scientific Notation when larger than"];
                sliderCell.slider.minimumValue = 0;
                sliderCell.slider.maximumValue = 3;
                if ([gSettingMaxDecimal unsignedIntValue] == 1000) {
                    sliderCell.slider.value = 0;
                } else if ([gSettingMaxDecimal unsignedIntValue] == 1000000) {
                    sliderCell.slider.value = 1;
                } else if ([gSettingMaxDecimal unsignedIntValue] == 1000000000) {
                    sliderCell.slider.value = 2;
                } else if ([gSettingMaxDecimal doubleValue] == 1000000000000) {
                    sliderCell.slider.value = 3;
                } else {
                    sliderCell.slider.value = 3;
                    gSettingMaxDecimal = [NSNumber numberWithDouble:1000000000000];
                }
                [sliderCell.slider addTarget:self action:@selector(sliderMaxDecimalValueChanged:) forControlEvents:UIControlEventValueChanged];
                cell = sliderCell;
            }
                break;
            default:
                break;
        }
    }
    
    return cell;
}

- (void) sliderFontSizeValueChanged:(UISlider *)sender {
    CGFloat v = roundf(sender.value);
    
    sender.value = v;
    
    if ((int)v != gSettingMainFontLevel) {
        gSettingMainFontLevel = (int)v;
        [self updateLabel];
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        NSLog(@"%s%i>~%@~~~~~~~~~~", __FUNCTION__, __LINE__, self.label.text);
    }
}

- (void) sliderMaxFracDigiValueChanged:(UISlider *)sender {
    CGFloat v = roundf(sender.value);
    
    sender.value = v;
    
    if ((int)v != gSettingMaxFractionDigits) {
        gSettingMaxFractionDigits = (int)v;
        [self updateLabel];
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        NSLog(@"%s%i>~%@~~~~~~~~~~", __FUNCTION__, __LINE__, self.label.text);
    }
}

- (void) sliderMaxDecimalValueChanged:(UISlider *)sender {
    CGFloat v = roundf(sender.value);
    
    sender.value = v;
    
    if (v == 0 && [gSettingMaxDecimal doubleValue] == 1000) {
        gSettingMaxDecimal = @(1000);
        goto update_label;
    } else if (v == 1 && [gSettingMaxDecimal doubleValue] != 1000000) {
        gSettingMaxDecimal = @(1000000);
        goto update_label;
    } else if (v == 2 && [gSettingMaxDecimal doubleValue] != 1000000000) {
        gSettingMaxDecimal = @(1000000000);
        goto update_label;
    } else if (v == 3 && [gSettingMaxDecimal doubleValue] != 1000000000000) {
        gSettingMaxDecimal = @(1000000000000);
        goto update_label;
    }
    
    return;
update_label:
    [self updateLabel];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    NSLog(@"%s%i>~%@~~~~~~~~~~", __FUNCTION__, __LINE__, self.label.text);
}

-(void)thousandSeparatorsSetting:(UISwitch *)sw{
    gSettingThousandSeperator = sw.on;
    [self updateLabel];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    NSLog(@"%s%i>~%@~~~~~~~~~~", __FUNCTION__, __LINE__, self.label.text);
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"%s%i>~%f~~~~~~~~~~", __FUNCTION__, __LINE__, cell.frame.size.height);
    return cell.frame.size.height;
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
