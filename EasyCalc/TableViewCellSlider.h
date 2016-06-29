//
//  TableViewCellSlider.h
//  EasyCalc
//
//  Created by LiBoli on 16/6/10.
//  Copyright © 2016年 LiBoli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASValueTrackingSlider.h"

@interface TableViewCellSlider : UITableViewCell <ASValueTrackingSliderDelegate>
@property ASValueTrackingSlider *slider;
@property UILabel *title;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier title:(NSString *)titleStr;
@end
