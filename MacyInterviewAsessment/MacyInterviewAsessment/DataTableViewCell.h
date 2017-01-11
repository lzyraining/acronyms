//
//  DataTableViewCell.h
//  MacyInterviewAsessment
//
//  Created by Zhuoyu Li on 1/10/17.
//  Copyright © 2017 ZhuoyuZhuoyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lfLabel;
@property (weak, nonatomic) IBOutlet UILabel *freqLabel;
@property (weak, nonatomic) IBOutlet UILabel *sinceLabel;

@end
