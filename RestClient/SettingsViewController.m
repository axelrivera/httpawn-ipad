//
//  SettingsViewController.m
//  RestClient
//
//  Created by Axel Rivera on 12/2/13.
//  Copyright (c) 2013 Axel Rivera. All rights reserved.
//

#import "SettingsViewController.h"

#import "SliderViewCell.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)init
{
    self = [super initWithNibName:@"SettingsViewController" bundle:nil];
    if (self) {
        self.title = @"Settings";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(dismissAction:)];

    CGFloat min = kRCSettingsTimeoutIntervalMinValue / kSecondSliderFactor;
    CGFloat max = kRCSettingsTimeoutIntervalMaxValue / kSecondSliderFactor;
    CGFloat value = (float)[[RCSettings defaultSettings] timeoutInterval] / kSecondSliderFactor;

    self.timeoutSlider = [[UISlider alloc] initWithFrame:CGRectZero];
    self.timeoutSlider.continuous = YES;
    self.timeoutSlider.minimumTrackTintColor = [UIColor rc_defaultTintColor];
    self.timeoutSlider.maximumTrackTintColor = [UIColor rc_defaultTintColor];
    self.timeoutSlider.minimumValue = min;
    self.timeoutSlider.maximumValue = max;
    self.timeoutSlider.value = value;
    [self.timeoutSlider addTarget:self action:@selector(timeoutChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Selector Methods

- (void)dismissAction:(id)sender
{
    NSInteger value = (int)(self.timeoutSlider.value * kSecondSliderFactor);
    [[RCSettings defaultSettings] setTimeoutInterval:value];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchAction:(UISwitch *)mySwitch
{
    NSInteger section = -1;
    NSInteger row = -1;
    if (mySwitch.tag >= 100 && mySwitch.tag < 200) {
        section = 0;
        row = mySwitch.tag - 100;
    } else {
        section = 1;
        row = mySwitch.tag - 200;
    }

    RCSettings *settings = [RCSettings defaultSettings];

    if (section == 0) {
        if (row == 0) {
            [settings setEnableCookies:[mySwitch isOn]];
        } else if (row == 1) {
            [settings setAllowInvalidSSL:[mySwitch isOn]];
        }
    } else if (section == 1) {
        if (row == 0) {
            [settings setUsePrettyPrintResponse:[mySwitch isOn]];
        } else if (row == 1) {
            [settings setApplySyntaxHighlighting:[mySwitch isOn]];
        } else if (row == 2) {
            [settings setIncludeLineNumbers:[mySwitch isOn]];
        }
    }
}

- (void)timeoutChanged:(UISlider *)slider
{
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    if (section == 0) {
        rows = 3;
    } else {
        rows = 3;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *SliderIdentifier = @"SliderCell";

    if (indexPath.section == 0 && indexPath.row == 2) {
        SliderViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SliderIdentifier];
        if (cell == nil) {
            cell = [[SliderViewCell alloc] initWithReuseIdentifier:SliderIdentifier];
            cell.slider = self.timeoutSlider;
        }

        cell.minLabel.text = [NSString stringWithFormat:@"%.0f s", kRCSettingsTimeoutIntervalMinValue];
        cell.maxLabel.text = [NSString stringWithFormat:@"%.0f s", kRCSettingsTimeoutIntervalMaxValue];

        return cell;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];

        UISwitch *mySwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [mySwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];

        cell.accessoryView = mySwitch;
    }
    
    UISwitch *mySwitch = (UISwitch *)cell.accessoryView;

    RCSettings *settings = [RCSettings defaultSettings];

    NSString *textStr = nil;
    BOOL isOn = NO;

    if (indexPath.section == 0) {
        mySwitch.tag = 100 + indexPath.row;
        if (indexPath.row == 0) {
            textStr = @"Store and Send Cookies Automatically";
            isOn = [settings enableCookies];
        } else {
            textStr = @"Allow Self-Signed and Unverified SSL Certificates";
            isOn = [settings allowInvalidSSL];
        }
    } else {
        mySwitch.tag = 200 + indexPath.row;
        if (indexPath.row == 0) {
            textStr = @"Show Pretty-Print Response";
            isOn = [settings usePrettyPrintResponse];
        } else if (indexPath.row == 1) {
            textStr = @"Apply Syntax Highlighting";
            isOn = [settings applySyntaxHighlighting];
        } else {
            textStr = @"Include Line Numbers";
            isOn = [settings includeLineNumbers];
        }
    }

    cell.textLabel.text = textStr;

    mySwitch.on = isOn;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    if (section == 0) {
        title = @"Requests";
    } else {
        title = @"Response Output";
    }
    return title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *title = nil;
    if (section == 1) {
        title = @"Pretty Print and Syntax Highlighting are only supported for JSON and XML.";
    }
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    if (indexPath.section == 0 && indexPath.row == 2) {
        height = 100.0;
    }
    return height;
}

@end
