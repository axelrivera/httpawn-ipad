//
//  JSONObjectViewController.m
//  RestClient
//
//  Created by Axel Rivera on 1/10/14.
//  Copyright (c) 2014 Axel Rivera. All rights reserved.
//

#import "JSONObjectViewController.h"

#import "JSONValueViewController.h"
#import "JSONDetailViewCell.h"

@interface JSONObjectViewController ()
<UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate, JSONValueViewControllerDelegate>

@property (strong, nonatomic) UIPopoverController *myPopoverController;

- (NSArray *)myToolbarItems;

@end

@implementation JSONObjectViewController

- (instancetype)init
{
    self = [super initWithNibName:@"JSONObjectViewController" bundle:nil];
    if (self) {
        self.title = @"JSON Object";
    }
    return self;
}

- (instancetype)initWithContainerObject:(RCJSONObject *)object
{
    self = [self init];
    if (self) {
        _object = object;

        if (object.parentObject == nil) {
            self.title = @"Object";
        } else {
            NSString *typeStr = nil;
            if (object.objectType == RCJSONObjectTypeObject) {
                typeStr = [RCJSONObject titleForObjectType:RCJSONObjectTypeObject];
            } else if (object.objectType == RCJSONObjectTypeArray) {
                typeStr = [RCJSONObject titleForObjectType:RCJSONObjectTypeArray];
            }

            self.title = [NSString stringWithFormat:@"%@ (%@)", object.objectKey, typeStr];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.toolbar.items = [self myToolbarItems];

    if (self.object.parentObject == nil) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                               target:self
                                                                                               action:@selector(saveAction:)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (NSArray *)myToolbarItems
{
    SEL action = @selector(objectAction:);

    UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                               target:nil
                                                                               action:nil];
    fixedItem.width = 20.0;

    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil];

    RCJSONObjectType objectType = RCJSONObjectTypeObject;

    UIBarButtonItem *objectItem = [[UIBarButtonItem alloc] initWithTitle:[RCJSONObject titleForObjectType:objectType]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:action];
    objectItem.tag = objectType;

    objectType = RCJSONObjectTypeArray;

    UIBarButtonItem *arrayItem = [[UIBarButtonItem alloc] initWithTitle:[RCJSONObject titleForObjectType:objectType]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:action];
    arrayItem.tag = objectType;

    objectType = RCJSONObjectTypeString;

    UIBarButtonItem *stringItem = [[UIBarButtonItem alloc] initWithTitle:[RCJSONObject titleForObjectType:objectType]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:action];
    stringItem.tag = objectType;

    objectType = RCJSONObjectTypeNumber;

    UIBarButtonItem *numberItem = [[UIBarButtonItem alloc] initWithTitle:[RCJSONObject titleForObjectType:objectType]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:action];
    numberItem.tag = objectType;

    objectType = RCJSONObjectTypeBoolean;

    UIBarButtonItem *booleanItem = [[UIBarButtonItem alloc] initWithTitle:[RCJSONObject titleForObjectType:objectType]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:action];
    booleanItem.tag = objectType;

    objectType = RCJSONObjectTypeNull;

    UIBarButtonItem *nullItem = [[UIBarButtonItem alloc] initWithTitle:[RCJSONObject titleForObjectType:objectType]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:action];
    nullItem.tag = objectType;

    return @[ fixedItem,
              objectItem,
              flexibleItem,
              arrayItem,
              flexibleItem,
              stringItem,
              flexibleItem,
              numberItem,
              flexibleItem,
              booleanItem,
              flexibleItem,
              nullItem,
              fixedItem ];
}

#pragma mark - Selector Methods

- (void)saveAction:(id)sender
{
    [self.delegate JSONObjectViewController:self didFinishWithObject:self.object];
}

- (void)objectAction:(id)sender
{
    if (self.myPopoverController) {
        [self.myPopoverController dismissPopoverAnimated:YES];
        self.myPopoverController = nil;
        return;
    }

    if (self.object.objectType == RCJSONObjectTypeArray &&
        ([sender tag] == RCJSONObjectTypeObject || [sender tag] == RCJSONObjectTypeArray || [sender tag] == RCJSONObjectTypeNull))
    {
        RCJSONObject *object = [[RCJSONObject alloc] init];
        object.objectType = [sender tag];
        object.objectKey = nil;
        object.parentObject = self.object;
        
        if ([sender tag] == RCJSONObjectTypeObject || [sender tag] == RCJSONObjectTypeArray) {
            object.objectValue = [@[] mutableCopy];
        } else {
            object.objectValue = [NSNull null];
        }

        [self.object.objectValue addObject:object];
        [self.tableView reloadData];

        return;
    }

    JSONValueViewController *controller = [[JSONValueViewController alloc] initWithObjectType:[sender tag]
                                                                                   parentType:self.object.objectType];
    controller.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];

    self.myPopoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
    self.myPopoverController.delegate = self;

    [self.myPopoverController presentPopoverFromBarButtonItem:sender
                                     permittedArrowDirections:UIPopoverArrowDirectionDown
                                                     animated:YES];
}

- (void)detailAction:(id)sender
{
        if (self.myPopoverController) {
            [self.myPopoverController dismissPopoverAnimated:YES];
            self.myPopoverController = nil;
            return;
        }

        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
        RCJSONObject *object = [self.object.objectValue objectAtIndex:[sender tag]];
        JSONDetailViewCell *cell = (JSONDetailViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        CGRect rect = [window convertRect:cell.button.frame fromWindow:window];
    
        NSString *tmpKey = [NSString stringWithFormat:@"Item[%d]", [sender tag]];
    
        JSONValueViewController *controller = [[JSONValueViewController alloc] initWithObject:object temporaryKey:tmpKey];
        controller.delegate = self;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];

        self.myPopoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
        self.myPopoverController.delegate = self;

        [self.myPopoverController presentPopoverFromRect:rect
                                                  inView:cell
                                permittedArrowDirections:UIPopoverArrowDirectionRight
                                                animated:YES];
}

#pragma mark - UIViewControllerDelegate Methods

- (void)JSONValueViewController:(JSONValueViewController *)controller
        didFinishWithObjectType:(RCJSONObjectType)objectType
                            key:(NSString *)key
                          value:(id)value
{


    if ([self.object isContainer]) {
        RCJSONObject *object = [[RCJSONObject alloc] init];
        object.objectType = objectType;
        object.objectKey = key;
        object.objectValue = value;
        object.parentObject = self.object;

        [self.object.objectValue addObject:object];

        [self.tableView reloadData];
    }

    [self.myPopoverController dismissPopoverAnimated:YES];
    self.myPopoverController = nil;
}

- (void)JSONValueViewControllerDidFinish:(JSONValueViewController *)controller
{
    [self.tableView reloadData];
    [self.myPopoverController dismissPopoverAnimated:YES];
    self.myPopoverController = nil;
}

- (void)JSONValueViewControllerDidCancel:(JSONValueViewController *)controller
{
    [self.myPopoverController dismissPopoverAnimated:YES];
    self.myPopoverController = nil;
}

- (void)JSONValueViewControllerShouldDeleteObject:(RCJSONObject *)object
{
    if ([self.object isContainer]) {
        [self.object.objectValue removeObject:object];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.myPopoverController dismissPopoverAnimated:YES];
        self.myPopoverController = nil;
    }
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.object.objectValue count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    JSONDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[JSONDetailViewCell alloc] initWithReuseIdentifier:CellIdentifier];
    }

    RCJSONObject *object = [self.object.objectValue objectAtIndex:indexPath.row];

    NSString *titleStr = nil;
    NSString *supportStr = nil;
    NSString *descriptionStr = nil;

    UITableViewCellSelectionStyle selectionStyle = UITableViewCellSelectionStyleNone;

    switch (object.objectType) {
        case RCJSONObjectTypeObject:
        case RCJSONObjectTypeArray:
        {
            if ([self.object isArray]) {
                titleStr = [NSString stringWithFormat:@"Item[%d]", indexPath.row];
            } else {
                titleStr = object.objectKey;
            }
            break;
        }

        case RCJSONObjectTypeString:
        case RCJSONObjectTypeNumber:
        case RCJSONObjectTypeBoolean:
        case RCJSONObjectTypeNull:
            if ([self.object isArray]) {
                titleStr = [NSString stringWithFormat:@"Item[%d]", indexPath.row];
            } else {
                titleStr = object.objectKey;
            }
            supportStr = [object stringValue];
            break;
        default:
            break;
    }

    descriptionStr = [RCJSONObject titleForObjectType:object.objectType];

    cell.titleLabel.text = titleStr;
    cell.supportLabel.text = supportStr;
    cell.descriptionLabel.text = descriptionStr;

    [cell.button addTarget:self action:@selector(detailAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.button.tag = indexPath.row;

    cell.selectionStyle = selectionStyle;

    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    RCJSONObject *object = [self.object.objectValue objectAtIndex:indexPath.row];
    if ([object isContainer]) {
        JSONObjectViewController *controller = [[JSONObjectViewController alloc] initWithContainerObject:object];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [JSONDetailViewCell cellHeight];
}

#pragma mark - UIPopoverControllerDelegate Methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.myPopoverController = nil;
}

@end
