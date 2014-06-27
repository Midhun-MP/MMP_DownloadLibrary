/*
 *  MMPDownloadManager.m
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

#import "MMPDownloadManager.h"
#import "MMPDownloadHelper.h"
#import "MMPDownloadConstants.h"
#import "MBProgressHUD.h"

@implementation MMPDownloadManager
{
    NSUInteger downloadedCount;
    NSUInteger needToDownloadCount;
    NSMutableArray *assets;
}

static MBProgressHUD *hud      = nil;

// Initializer
- (id)init
{
    self = [super init];
    if (self)
    {
        _successfullDownloads   = kMMPDefault;
        _failedDownloads        = kMMPDefault;
        _maxConcurrentDownloads = kMMPConcurrentDownloads;
        _showHUD                = YES;
    }
    return self;
}

#pragma mark - Private Methods

/**
 * Used for getting document directory path
 * @return (NSString *) Contains the document directory path
 */
- (NSString *)getDocDirectoryPath
{
    NSString *docDirPath = @"";
    @try
    {
        docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    }
    @catch (NSException *exception)
    {
        NSLog(@"\n--- %s, Exception \n Name : %@ Reason : %@ ", __PRETTY_FUNCTION__, exception.name, exception.reason);
    }
    return docDirPath;
}

// Creates folder structure and set the path to save the files
- (void)addAssetDownload
{
    @try
    {
        MMPDownloadHelper *info = nil;
        NSString *assetFolder = nil;
        BOOL createDirectory  = YES;
        
        [assets removeAllObjects];
        for (int index = 0; index<needToDownloadCount; index++)
        {
            info                                    = [_delegate assetForDownloading:index];
            assetFolder                             = [NSString stringWithFormat:@"%@/%@/%@",[self getDocDirectoryPath],info.assetFolder,info.assetName];
            createDirectory                         = YES;
            
            if ([info.assetFolder isEqualToString:@""] || !info.assetFolder)
            {
                assetFolder     = [NSString stringWithFormat:@"%@/%@",[self getDocDirectoryPath],info.assetName];
                createDirectory = NO;
            }
            
            if (createDirectory)
            {
                NSString *fileFolder = [assetFolder stringByDeletingLastPathComponent];
                BOOL isDirectory = YES;
                if (![[NSFileManager defaultManager] fileExistsAtPath:fileFolder isDirectory:&isDirectory])
                {
                    [[NSFileManager defaultManager] createDirectoryAtPath:fileFolder withIntermediateDirectories:YES attributes:nil error:nil];
                }
            }
            info.assetFolder = assetFolder;
            [assets addObject:info];
        }
        downloadedCount     = 0;
        needToDownloadCount = [_assetsToDownload count];
    }
    @catch (NSException *exception)
    {
        NSLog(@"\n--- %s, Exception \n Name : %@ Reason : %@ ", __PRETTY_FUNCTION__, exception.name, exception.reason);
    }
}


// Download handler
- (void)downloadFiles
{
    @try
    {
        [self updateProgress];
        
        if ([_assetsToDownload count] > kMMPDefault)
        {
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            queue.maxConcurrentOperationCount = _maxConcurrentDownloads;
            
            NSBlockOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self downloadAssets];
                }];
            }];
            
            for (MMPDownloadHelper *helper in assets)
            {
                if (![[NSFileManager defaultManager] fileExistsAtPath:helper.assetFolder])
                {
                    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                        downloadedCount++;
                        NSData *data = [NSData dataWithContentsOfURL:helper.assetURL];
                        NSString *filename = helper.assetFolder;
                        if (![[NSFileManager defaultManager] fileExistsAtPath:filename] && data != nil)
                        {
                            if([data writeToFile:filename atomically:YES])
                            {
                                _successfullDownloads++;
                                [self assetDowloadedSuccessfully:helper];
                            }
                            else
                            {
                                _failedDownloads++;
                                [self downloadFailed:helper withErrorCode:kMMPFileWriteFailed];
                            }
                        }
                        else
                        {
                            _failedDownloads++;
                            [self downloadFailed:helper withErrorCode:kMMPInvalidURL];
                        }
                        [self updateProgress];
                        
                    }];
                    [completionOperation addDependency:operation];
                }
                else
                {
                    [self downloadFailed:helper withErrorCode:kMMPFileExists];
                    downloadedCount++;
                    _successfullDownloads++;
                    [self updateProgress];
                }
                [_assetsToDownload removeObject:helper];
            }
            
            [queue addOperations:completionOperation.dependencies waitUntilFinished:NO];
            [queue addOperation:completionOperation];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"\n--- %s, Exception \n Name : %@ Reason : %@ ", __PRETTY_FUNCTION__, exception.name, exception.reason);
    }
}

#pragma mark - HUD

// Displays the activity indicator
- (void)showHUD:(NSString *)message
{
    @try
    {
        if (_showHUD)
        {
            // Ensuring main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_downloadView)
                {
                    if (!hud)
                    {
                        hud = [[MBProgressHUD alloc] initWithView:_downloadView];
                        [_downloadView addSubview:hud];
                    }
                    [hud show:NO];
                    [hud setMode:MBProgressHUDModeAnnularDeterminate];
                    [hud setLabelText:message];
                    [hud setNeedsDisplay];
                }
            });
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%@ Exception in %s on %d due to %@",[exception name],__PRETTY_FUNCTION__,__LINE__,[exception reason]);
    }
}


// Hides the activity indicator
- (void)hideHUD
{
    @try
    {
        // Ensuring main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            if (hud)
            {
                [hud hide:NO];
                [hud removeFromSuperview];
                
                hud           = nil;
                _downloadView = nil;
            }
        });
    }
    @catch (NSException *exception)
    {
        NSLog(@"%@ Exception in %s on %d due to %@",[exception name],__PRETTY_FUNCTION__,__LINE__,[exception reason]);
    }
}


// Updates the downloading Progress
- (void)updateProgress
{
    @try
    {
        [hud setProgress:((float)downloadedCount/needToDownloadCount)];
        [self showHUD:[NSString stringWithFormat:@"Downloading (%d/%d)",downloadedCount, needToDownloadCount]];
    }
    @catch (NSException *exception)
    {
        NSLog(@"%@ Exception in %s on %d due to %@",[exception name],__PRETTY_FUNCTION__,__LINE__,[exception reason]);
    }
}

#pragma mark - Utility Methods

// Utility method that passes the download success message to delegate
- (void)assetDowloadedSuccessfully:(MMPDownloadHelper *)asset
{
    @try
    {
        if ([_delegate respondsToSelector:@selector(downloadSuccessFullForAsset:)])
        {
            [_delegate downloadSuccessFullForAsset:asset];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%@ Exception in %s on %d due to %@",[exception name],__PRETTY_FUNCTION__,__LINE__,[exception reason]);
    }
}

// Utility method that passes the download failure message to delegate
- (void)downloadFailed:(MMPDownloadHelper *)asset withErrorCode:(MMPDownloadErrorCode)errorcode
{
    @try
    {
        NSError *error = [NSError errorWithDomain:kMMPErrorDomain code:errorcode userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[kMMPErrorDesc objectAtIndex:(errorcode-kMMPFileExists)],kMMPErrorKey,nil]];
        
        if ([_delegate respondsToSelector:@selector(downloadFailedWithError:forAsset:)])
        {
            [_delegate downloadFailedWithError:error forAsset:asset];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%@ Exception in %s on %d due to %@",[exception name],__PRETTY_FUNCTION__,__LINE__,[exception reason]);
    }
}

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
- (void)downloadAssets
{
    @try
    {
        needToDownloadCount = [_delegate numberOfAssetstoDownload];
        if (!needToDownloadCount)
        {
            [self hideHUD];
        }
        else
        {
            assets = [[NSMutableArray alloc] init];
            [self addAssetDownload];
            [self downloadFiles];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"\n--- %s, Exception \n Name : %@ Reason : %@ ", __PRETTY_FUNCTION__, exception.name, exception.reason);
    }
}

#pragma mark - Custom Getters
// Get Failed download count
- (NSUInteger)getFailedDownloads
{
    _failedDownloads = [assets count] - _successfullDownloads;
    return _failedDownloads;
}
@end
