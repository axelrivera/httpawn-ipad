//
//  RequestInputViewController.m
//  RestClient
//
//  Created by Axel Rivera on 11/16/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "RequestInputViewController.h"

#import "UIViewController+Layout.h"
#import <UIView+AutoLayout.h>

#import "RCRequestOption.h"
#import "RequestInputCell.h"

@interface RequestInputViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIBarButtonItem *doneButton;
@property (strong, nonatomic) UIBarButtonItem *clearButton;
@property (assign, nonatomic) CGFloat tableOrigin;

@end

@implementation RequestInputViewController

- (id)init
{
    return [self initWithType:RequestInputTypeHeaders dataSource:@[]];
}

- (id)initWithType:(RequestInputType)inputType dataSource:(NSArray *)dataSource
{
    self = [super initWithNibName:@"RequestInputViewController" bundle:nil];
    if (self) {
        _inputType = inputType;
        if (IsEmpty(dataSource)) {
            dataSource = @[];
        }
        _dataSource = [dataSource mutableCopy];

        if (inputType == RequestInputTypeHeaders) {
            self.title = @"Headers";
        } else {
            self.title = @"Parameters";
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!IsEmpty(self.dataSource)) {
        self.navigationItem.leftBarButtonItem = [self editButtonItem];
    }

    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                    target:self
                                                                    action:@selector(dismissAction:)];

    self.clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear All"
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(clearAllConfirmation:)];

    self.navigationItem.rightBarButtonItem = self.doneButton;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidChangeFrame:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableOrigin = self.topOrigin;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
}

#pragma mark - Public Methods

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];

    NSArray *cells = [self.tableView visibleCells];
    for (id cell in cells) {
        if ([cell isKindOfClass:[RequestInputCell class]]) {
            [[cell nameTextField] setEnabled:!editing];
            [[cell valueTextField] setEnabled:!editing];
            [[cell activeSwitch] setEnabled:!editing];
        }
    }

    if (editing) {
        self.navigationItem.rightBarButtonItem = self.clearButton;
    } else {
        self.navigationItem.rightBarButtonItem = self.doneButton;
    }

    [self.tableView reloadData];
}

#pragma mark - Selector Methods

- (void)clearAllConfirmation:(id)sender
{
    NSString *message = @"Are you sure you want to remove all the inputs?";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Clear Inputs"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Continue", nil];

    [alertView show];
}

- (void)clearAction:(id)sender
{
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    [self setEditing:NO animated:YES];
}

- (void)dismissAction:(id)sender
{
    [self.delegate requestInputViewController:self didFinishWithInputType:self.inputType objects:self.dataSource];
}

- (void)keyboardDidChangeFrame:(NSNotification*)notification
{
    NSDictionary *info = [notification userInfo];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGRect kbFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect kbIntersectFrame = [window convertRect:CGRectIntersection(window.frame, kbFrame) toView:self.tableView];

    // get point before contentInset change
    CGPoint pointBefore = self.tableView.contentOffset;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableOrigin, 0.0, kbIntersectFrame.size.height, 0.0);

    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;

    // get point after contentInset change
    CGPoint pointAfter = self.tableView.contentOffset;

    // avoid jump by settings contentOffset
    self.tableView.contentOffset = pointBefore;

    // and now animate smoothly
    [self.tableView setContentOffset:pointAfter animated:YES];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sections = 0;
    if (self.isEditing) {
        sections = 1;
    } else {
        sections = 2;
    }

    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if (self.isEditing) {
        rows = [self.dataSource count];
    } else {
        if (section == 0) {
            rows = [self.dataSource count];
        } else {
            rows = 1;
        }
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *AddIdentifier = @"AddCell";
    static NSString *CellIdentifier = @"Cell";

    if (!self.isEditing && indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AddIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddIdentifier];
        }

        if (self.inputType == RequestInputTypeHeaders) {
            cell.textLabel.text = @"Add Header";
        } else {
            cell.textLabel.text = @"Add Parameter";
        }

        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryNone;

        return cell;
    }

    RequestInputCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[RequestInputCell alloc] initWithReuseIdentifier:CellIdentifier];

        if (self.inputType == RequestInputTypeHeaders) {
            cell.nameTextField.placeholder = @"Header Name";
            cell.valueTextField.placeholder = @"Header Value";
        } else {
            cell.nameTextField.placeholder = @"Parameter Name";
            cell.valueTextField.placeholder = @"Parameter Value";
        }
    }
    
    cell.requestOption = self.dataSource[indexPath.row];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (self.isEditing) {
        return;
    }

    if (indexPath.section == 0) {
        return;
    }

    RCRequestOption *option = [[RCRequestOption alloc] init];

    if (self.dataSource == nil) {
        self.dataSource = [@[] mutableCopy];
    }

    [self.dataSource addObject:option];

    if (!IsEmpty(self.dataSource) && self.navigationItem.leftBarButtonItem == nil) {
        self.navigationItem.leftBarButtonItem = [self editButtonItem];
    }

    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(id)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[RequestInputCell class]]) {
        [[cell nameTextField] setEnabled:!tableView.isEditing];
        [[cell valueTextField] setEnabled:!tableView.isEditing];
        [[cell activeSwitch] setEnabled:!tableView.isEditing];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
        return UITableViewCellEditingStyleDelete;
    }

    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.dataSource removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];

        if (IsEmpty(self.dataSource)) {
            self.navigationItem.leftBarButtonItem = nil;
            [self setEditing:NO animated:YES];
        }
    }
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    RCRequestOption *inputObject = self.dataSource[fromIndexPath.row];
    [self.dataSource removeObjectAtIndex:fromIndexPath.row];
    [self.dataSource insertObject:inputObject atIndex:toIndexPath.row];
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self clearAction:alertView];
    }
}

@end
