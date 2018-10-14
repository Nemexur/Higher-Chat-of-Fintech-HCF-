//
//  ThemesViewController.h
//  Higher Chat of Fintech
//
//  Created by Alex Milogradsky on 11/10/2018.
//  Copyright © 2018 Alex Milogradsky. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class Themes;
@class ThemesViewController;

@protocol ThemesViewControllerDelegate <NSObject>

@required
- (void)themesViewController: (ThemesViewController *)controller didSelectTheme:(UIColor *)selectedTheme;

@end

@interface ThemesViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIView *topBarThemeView;
@property (weak, nonatomic) id <ThemesViewControllerDelegate> delegate;
@property (weak, nonatomic) Themes* themes;

@end

NS_ASSUME_NONNULL_END
