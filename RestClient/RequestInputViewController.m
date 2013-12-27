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
#import "HeaderSelectViewController.h"
#import "RCRequestOption.h"
#import "RequestInputCell.h"

@interface RequestInputViewController () <UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *myPopoverController;

@property (strong, nonatomic) UIBarButtonItem *doneButton;
@property (strong, nonatomic) UIBarButtonItem *addButton;
@property (strong, nonatomic) UIBarButtonItem *clearButton;

@property (strong, nonatomic) NSArray *rightItems;
@property (strong, nonatomic) NSArray *editingRightItems;

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

        _myPopoverController = nil;
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

    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                   target:self
                                                                   action:@selector(addAction:)];

    self.clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear All"
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(clearAction:)];

    self.rightItems = @[ self.doneButton, self.addButton ];
    self.editingRightItems = @[ self.clearButton ];

    [self.navigationItem setRightBarButtonItems:self.rightItems];

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
            [[cell inputButton] setEnabled:!editing];
            [[cell nameTextField] setEnabled:!editing];
            [[cell valueTextField] setEnabled:!editing];
            [[cell activeSwitch] setEnabled:!editing];
        }
    }

    if (editing) {
        [self.navigationItem setRightBarButtonItems:self.editingRightItems animated:YES];
    } else {
        [self.navigationItem setRightBarButtonItems:self.rightItems animated:YES];
    }

    [self.tableView reloadData];
}

#pragma mark - Selector Methods

- (void)addAction:(id)sender
{
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

- (void)headerAction:(id)sender
{
    if (self.myPopoverController) {
        [self.myPopoverController dismissPopoverAnimated:YES];
        self.myPopoverController = nil;
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[sender tag] inSection:0];
    RequestInputCell *cell = (RequestInputCell *)[self.tableView cellForRowAtIndexPath:indexPath];

    HeaderSelectViewController *controller = [[HeaderSelectViewController alloc] init];

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];

    self.myPopoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
    self.myPopoverController.delegate = self;

    controller.saveBlock = ^(NSString *name, NSString *value) {
        RCRequestOption *requestOption = self.dataSource[indexPath.row];

        requestOption.objectName = cell.nameTextField.text = name;
        requestOption.objectValue = cell.valueTextField.text = value;
        [self.myPopoverController dismissPopoverAnimated:YES];
    };

    controller.cancelBlock = ^{
        [self.myPopoverController dismissPopoverAnimated:YES];
    };

    [self.myPopoverController presentPopoverFromRect:cell.inputButton.frame
                                              inView:cell
                            permittedArrowDirections:UIPopoverArrowDirectionLeft
                                            animated:YES];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    RequestInputCellType cellType = self.inputType == RequestInputCellTypeHeader ? RequestInputCellTypeHeader : RequestInputCellTypeParameter;

    RequestInputCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[RequestInputCell alloc] initWithType:cellType reuseIdentifier:CellIdentifier];

        if (self.inputType == RequestInputTypeHeaders) {
            cell.nameTextField.placeholder = @"Header Name";
            cell.valueTextField.placeholder = @"Header Value";
            cell.inputButton.tag = indexPath.row;
            [cell.inputButton addTarget:self action:@selector(headerAction:) forControlEvents:UIControlEventTouchUpInside];
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
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(id)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[RequestInputCell class]]) {
        [[cell inputButton] setEnabled:!tableView.isEditing];
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

#pragma mark - UIPopoverControllerDelegate Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.myPopoverController = nil;
}

@end
