////////////////////////////////////////////////////////////////////////////////
//
// B L I N K
//
// Copyright (C) 2016 Blink Mobile Shell Project
//
// This file is part of Blink.
//
// Blink is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Blink is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Blink. If not, see <http://www.gnu.org/licenses/>.
//
// In addition, Blink is also subject to certain additional terms under
// GNU GPL version 3 section 7.
//
// You should have received a copy of these additional terms immediately
// following the terms and conditions of the GNU General Public License
// which accompanied the Blink Source Code. If not, see
// <http://www.github.com/blinksh/blink>.
//
////////////////////////////////////////////////////////////////////////////////

#import "BKAppearanceViewController.h"
#import "BKDefaults.h"
#import "BKFont.h"
#import "BKTheme.h"

#define FONT_SIZE_FIELD_TAG 2001
#define FONT_SIZE_STEPPER_TAG 2002

@interface BKAppearanceViewController ()

@property (nonatomic, strong) NSIndexPath *selectedFontIndexPath;
@property (nonatomic, strong) NSIndexPath *selectedThemeIndexPath;
@property (weak, nonatomic) UITextField *fontSizeField;
@property (weak, nonatomic) UIStepper *fontSizeStepper;

@end

@implementation BKAppearanceViewController

- (void)viewDidLoad
{
  [self loadDefaultValues];
  [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  [self saveDefaultValues];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
}

- (void)loadDefaultValues
{
  NSString *selectedThemeName = [BKDefaults selectedThemeName];
  BKTheme *selectedTheme = [BKTheme withTheme:selectedThemeName];
  if (selectedTheme != nil) {
    _selectedThemeIndexPath = [NSIndexPath indexPathForRow:[[BKTheme all] indexOfObject:selectedTheme] inSection:0];
  }
  NSString *selectedFontName = [BKDefaults selectedFontName];
  BKFont *selectedFont = [BKFont withFont:selectedFontName];
  if (selectedFont != nil) {
    _selectedFontIndexPath = [NSIndexPath indexPathForRow:[[BKFont all] indexOfObject:selectedFont] inSection:1];
  }
}

- (void)saveDefaultValues
{
  if (_fontSizeField.text != nil && ![_fontSizeField.text isEqualToString:@""]) {
    [BKDefaults setFontSize:[NSNumber numberWithInt:_fontSizeField.text.intValue]];
  }
  if (_selectedFontIndexPath != nil) {
    [BKDefaults setFontName:[[[BKFont all] objectAtIndex:_selectedFontIndexPath.row] name]];
  }
  if (_selectedThemeIndexPath != nil) {
    [BKDefaults setThemeName:[[[BKTheme all] objectAtIndex:_selectedThemeIndexPath.row] name]];
  }
  [BKDefaults saveDefaults];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == 0) {
    return [[BKTheme all] count] + 1;
  } else if (section == 1) {
    return [[BKFont all] count] + 1;
  } else {
    return 1;
  }
}

- (void)setFontsUIForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == [[BKFont all] count]) {
    cell.textLabel.text = @"Add a new font";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  } else {
    if (_selectedFontIndexPath == indexPath) {
      [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
      [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    cell.textLabel.text = [[[BKFont all] objectAtIndex:indexPath.row] name];
  }
}

- (void)setThemesUIForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.row == [[BKTheme all] count]) {
    cell.textLabel.text = @"Add a new theme";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  } else {
    if (_selectedThemeIndexPath == indexPath) {
      [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
      [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    cell.textLabel.text = [[[BKTheme all] objectAtIndex:indexPath.row] name];
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0 || indexPath.section == 1) {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"themeFontCell" forIndexPath:indexPath];
    if (indexPath.section == 0) {
      [self setThemesUIForCell:cell atIndexPath:indexPath];
    } else {
      [self setFontsUIForCell:cell atIndexPath:indexPath];
    }
    return cell;
  } else {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fontSizeCell" forIndexPath:indexPath];
    _fontSizeField = [cell viewWithTag:FONT_SIZE_FIELD_TAG];
    _fontSizeStepper = [cell viewWithTag:FONT_SIZE_STEPPER_TAG];
    if ([BKDefaults selectedFontSize] != nil) {
      _fontSizeStepper.value = [BKDefaults selectedFontSize].integerValue;
      _fontSizeField.text = [NSString stringWithFormat:@"%@ px", [BKDefaults selectedFontSize]];
    } else {
      _fontSizeField.placeholder = @"10 px";
    }
    return cell;
  }
  // Configure the cell...
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0) {
    if (indexPath.row == [[BKTheme all] count]) {
      [self performSegueWithIdentifier:@"addTheme" sender:self];
    } else {
      if (_selectedThemeIndexPath != nil) {
        // When in selectable mode, do not show details.
        [[tableView cellForRowAtIndexPath:_selectedThemeIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
      }
      _selectedThemeIndexPath = indexPath;
      [tableView deselectRowAtIndexPath:indexPath animated:YES];
      [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
  } else if (indexPath.section == 1) {
    if (indexPath.row == [[BKFont all] count]) {
      [self performSegueWithIdentifier:@"addFont" sender:self];
    } else {
      if (_selectedFontIndexPath != nil) {
        // When in selectable mode, do not show details.
        [[tableView cellForRowAtIndexPath:_selectedFontIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
      }
      _selectedFontIndexPath = indexPath;
      [tableView deselectRowAtIndexPath:indexPath animated:YES];
      [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
  }
}

- (IBAction)unwindFromAddFont:(UIStoryboardSegue *)sender
{
  int lastIndex = (int)[BKFont count];
  if (![self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastIndex inSection:1]]) {
    [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:lastIndex - 1 inSection:1] ] withRowAnimation:UITableViewRowAnimationBottom];
  }
}

- (IBAction)unwindFromAddTheme:(UIStoryboardSegue *)sender
{
  int lastIndex = (int)[BKTheme count];
  if (![self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastIndex inSection:0]]) {
    [self.tableView insertRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:lastIndex - 1 inSection:0] ] withRowAnimation:UITableViewRowAnimationBottom];
  }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Return NO if you do not want the specified item to be editable.
  if ((indexPath.section == 0 && indexPath.row < [BKTheme count]) || (indexPath.section == 1 && indexPath.row < [BKFont count])) {
    return YES;
  } else {
    return NO;
  }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    // Delete the row from the data source
    if (indexPath.section == 0) {
      [BKTheme removeThemeAtIndex:(int)indexPath.row];

      if (indexPath.row < _selectedThemeIndexPath.row) {
        _selectedThemeIndexPath = [NSIndexPath indexPathForRow:_selectedThemeIndexPath.row - 1 inSection:0];
      } else if (indexPath.row == _selectedThemeIndexPath.row) {
        _selectedThemeIndexPath = nil;
      }

    } else if (indexPath.section == 1) {
      [BKFont removeFontAtIndex:(int)indexPath.row];

      if (indexPath.row < _selectedFontIndexPath.row) {
        _selectedFontIndexPath = [NSIndexPath indexPathForRow:_selectedFontIndexPath.row - 1 inSection:0];
      } else if (indexPath.row == _selectedFontIndexPath.row) {
        _selectedFontIndexPath = nil;
      }
    }
    [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
  } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
  }
}
- (IBAction)stepperButtonPressed:(id)sender
{
  _fontSizeField.text = [NSString stringWithFormat:@"%d px", (int)[_fontSizeStepper value]];
}

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