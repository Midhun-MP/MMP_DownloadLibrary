/*
 *  MMPDownloadManager.h
 *  MMPLibrary
 *  Created by Midhun on 29/05/14.
 *  Copyright (c) 2014 Midhun. All rights reserved.
 *  This class is used for managing the file download functionality
 *
 *----------
 * LICENSE
 *----------
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the
 *  "Software"), to deal in the Software without restriction, including
 *  without limitation the rights to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the Software, and to
 *  permit persons to whom the Software is furnished to do so, subject to
 *  the following conditions:
 *
 *  The above copyright notice and this permission notice shall be
 *  included in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 *  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 *  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 *  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 *  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 *  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <Foundation/Foundation.h>

@interface MMPDownloadManager : NSObject

#pragma mark - Properties

// Holds the assests information, that need to be downloaded
@property (nonatomic, strong) NSMutableArray *assetsToDownload;

// Holds the View for displaying the progress
@property (nonatomic, strong) UIView *downloadView;


// Keeps the successfull download count
@property (nonatomic, assign) NSUInteger successfullDownloads;

// Keeps the failed download count
@property (nonatomic, readonly) NSUInteger failedDownloads;

// Concurrent downloads count
@property (nonatomic, assign) NSUInteger maxConcurrentDownloads;

// Determines whether need to show the HUD or not, default YES
@property (nonatomic, assign) BOOL showHUD;

#pragma mark - Public Methods

/**
 * Initiates the downloading
 * @code
 * MMPDownloadManager *manager = [[MMPDownloadManager alloc] init];
 * [manager setAssetsToDownload:asset]; // assets contains the MMPDownloadHelper objects
 * [manager setDownloadView:self.view];
 * [manager downloadAssets];
 * @endcode
 */
- (void)downloadAssets;


@end
