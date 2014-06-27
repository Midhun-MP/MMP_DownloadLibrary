/*
 *  MMPDownloadConstants.h
 *  MMPDownloadLibrary
 *  Created by Midhun on 26/06/14.
 *  Copyright (c) 2014 Midhun. All rights reserved.
 *  Header file that contains the constants
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

#ifndef MMPDownloadLibrary_MMPDownloadConstants_h
#define MMPDownloadLibrary_MMPDownloadConstants_h

#pragma mark - Constants

#define kMMPDefault 0
#define kMMPConcurrentDownloads 4
#define kMMPErrorDomain @"com.midhun.mp.mmpdownloadlibrary"
#define kMMPErrorKey @"Reason"
#define kMMPErrorDesc [NSArray arrayWithObjects:@"File already exist at the path",@"File not found at server/ URL broken",@"File could not saved to the path",nil]

#pragma mark - Enums

typedef enum MMPDownloadErrorCode
{
    kMMPFileExists = 13,
    kMMPInvalidURL,
    kMMPFileWriteFailed
}MMPDownloadErrorCode;

#endif
