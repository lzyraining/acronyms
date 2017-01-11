//
//  DetailViewController.m
//  MacyInterviewAsessment
//
//  Created by Zhuoyu Li on 1/10/17.
//  Copyright © 2017 ZhuoyuZhuoyu. All rights reserved.
//

#import "DetailViewController.h"
#import "DataModel.h"
#import "DataTableViewCell.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *fullFormLabel;
@property (weak, nonatomic) IBOutlet UITableView *detailTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UILabel *orderLabel;
@property (weak, nonatomic) IBOutlet UIButton *orderBtn;

@property (strong, nonatomic) NSMutableArray *presentedArray;

@end

@implementation DetailViewController

@synthesize data, fullForm;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.fullFormLabel.text = self.fullForm;
    [self getCellData];
    [self.orderBtn setSelected:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getCellData {
    _presentedArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in self.data) {
        DataModel *dataModel = [[DataModel alloc] init];
        dataModel.lf = [dict valueForKey:@"lf"];
        dataModel.freq = [NSString stringWithFormat:@"%@",[dict valueForKey:@"freq"]];
        dataModel.since = [NSString stringWithFormat:@"%@",[dict valueForKey:@"since"]];
        dataModel.vars = [dict valueForKey:@"vars"];
        [_presentedArray addObject:dataModel];
    }
    [self.detailTableView reloadData];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.presentedArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"baseCell";
    DataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    DataModel *dataModel = [self.presentedArray objectAtIndex:indexPath.row];
    cell.lfLabel.text = dataModel.lf;
    cell.freqLabel.text = dataModel.freq;
    cell.sinceLabel.text = dataModel.since;
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Similar Results: %ld", self.presentedArray.count];
}

- (IBAction)backBtn_tapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)segment_tapped:(id)sender {
    [self orderTheCell];
}

- (IBAction)orderBtn_tapped:(id)sender {
    _orderBtn.selected = !_orderBtn.selected;
    if (_orderBtn.selected) {
        _orderLabel.text = @"Descending";
    }
    else {
        _orderLabel.text = @"Ascending";
    }
    [self orderTheCell];
}

-(void) orderTheCell {
    NSArray *array = [[NSArray alloc] initWithArray:self.presentedArray];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor alloc];
    if (_segment.selectedSegmentIndex == 0) {
        if (_orderBtn.selected) {
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"freq" ascending:YES comparator:^(id obj1, id obj2){
                return [(NSString*)obj1 compare:(NSString*)obj2
                                        options:NSNumericSearch];
            }];
        }
        else {
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"freq" ascending:NO comparator:^(id obj1, id obj2){
                return [(NSString*)obj1 compare:(NSString*)obj2
                                        options:NSNumericSearch];
            }];
        }
    }
    else {
        if (_orderBtn.selected) {
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"since" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        }
        else {
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"since" ascending:NO selector:@selector(caseInsensitiveCompare:)];
        }
    }
    array = [array sortedArrayUsingDescriptors:@[sortDescriptor]];
    _presentedArray = [NSMutableArray arrayWithArray:array];
    [self.detailTableView reloadData];
}
@end
