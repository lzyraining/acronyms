//
//  ViewController.m
//  MacyInterviewAsessment
//
//  Created by Zhuoyu Li on 1/10/17.
//  Copyright © 2017 ZhuoyuZhuoyu. All rights reserved.
//

#import "ViewController.h"
#import "DataModel.h"
#import "DataTableViewCell.h"
#import "DetailViewController.h"
#import "MBProgressHUD.h"
#import <AFNetworking.h>

#define BASEURL @"http://www.nactem.ac.uk/software/acromine/dictionary.py?"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *shortFormTextField;
@property (weak, nonatomic) IBOutlet UITextField *fullFormTextField;
@property (weak, nonatomic) IBOutlet UITableView *dataTableView;
@property (weak, nonatomic) IBOutlet UIView *subView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UILabel *orderLabel;
@property (weak, nonatomic) IBOutlet UIButton *orderBtn;

@property (strong, nonatomic) NSArray *dataModelArray;
@property (strong, nonatomic) NSMutableArray *presentedArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.dataModelArray = [[NSArray alloc] init];
    self.presentedArray = [[NSMutableArray alloc] init];
    [self.subView setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self.dataTableView reloadData];
    [self.orderBtn setSelected:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) startNetWork {
    NSURL *url = [NSURL URLWithString:BASEURL];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    NSDictionary *parameters = @{@"sf": [NSString stringWithFormat:@"%@",self.shortFormTextField.text],@"lf": [NSString stringWithFormat:@"%@",self.fullFormTextField.text]};
    
    [manager GET:@"resources.json" parameters:parameters success:^(NSURLSessionDataTask *operation, id responseObject) {
        
        NSArray *json = (NSArray *)responseObject;
        if (json.count) {
            self.dataModelArray = [self parseJSONWithDataModel:json];
            self.presentedArray = [[NSMutableArray alloc] initWithArray:_dataModelArray];
            
        }
        else {
            self.presentedArray = [[NSMutableArray alloc] init];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.subView setHidden:NO];
        [self.dataTableView reloadData];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        NSLog(@"Error: %@", [error description]);
    }];
}

-(NSArray*) parseJSONWithDataModel: (NSArray *)json {
    NSArray *lfsArray = [json[0] valueForKey:@"lfs"];
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in lfsArray) {
        DataModel *data = [[DataModel alloc] init];
        data.lf = [dict valueForKey:@"lf"];
        data.freq = [NSString stringWithFormat:@"%@",[dict valueForKey:@"freq"]];
        data.since = [NSString stringWithFormat:@"%@",[dict valueForKey:@"since"]];
        data.vars = [dict valueForKey:@"vars"];
        [dataArray addObject:data];
    }
    return dataArray;
}

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.shortFormTextField resignFirstResponder];
    [self.fullFormTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}// called when 'return' key pressed. return NO to ignore.

- (IBAction)clearBtn_tapped:(id)sender {
    [self.shortFormTextField setText:@""];
    [self.fullFormTextField setText:@""];
    self.presentedArray = nil;
    [self.subView setHidden:YES];
    [self.dataTableView reloadData];
}

- (IBAction)searchBtn_tapped:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Search...";
    [self startNetWork];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.presentedArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"baseCell";
    DataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    DataModel *data = [self.presentedArray objectAtIndex:indexPath.row];
    cell.lfLabel.text = data.lf;
    cell.freqLabel.text = data.freq;
    cell.sinceLabel.text = data.since;
    
    if (data.vars.count > 1) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    }
    else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DataTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    DataModel *data = [self.presentedArray objectAtIndex:indexPath.row];
    if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        DetailViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
        detailVC.fullForm = data.lf;
        detailVC.data = data.vars;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:@"Search Results: %ld", self.presentedArray.count];
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
        if (!_orderBtn.selected) {
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
        if (!_orderBtn.selected) {
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"since" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        }
        else {
            sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"since" ascending:NO selector:@selector(caseInsensitiveCompare:)];
        }
    }
    array = [array sortedArrayUsingDescriptors:@[sortDescriptor]];
    _presentedArray = [NSMutableArray arrayWithArray:array];
    [self.dataTableView reloadData];
}

@end
