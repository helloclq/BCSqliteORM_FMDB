//
//  BCORMHeader.h
//  BCDBHelper-FMDB-ORM
//
//  Created by BlockCheng on 8/17/15.
//  Copyright (c) 2015 BlockCheng. All rights reserved.
//

#ifndef BCDBHelper_FMDB_ORM_BCORMHeader_h
#define BCDBHelper_FMDB_ORM_BCORMHeader_h

#if !defined(BC_INLINE)
# if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
#  define BC_INLINE static inline
# elif defined(__cplusplus)
#  define BC_INLINE static inline
# elif defined(__GNUC__)
#  define BC_INLINE static __inline__
# elif defined(__WIN32__)
#  define BC_INLINE static __inline
# else
#  define BC_INLINE static
# endif


#if !defined(BC_EXTERN)
# if defined(__WIN32__)
#  if defined(BC_BUILDING_BC)
#   if defined(__cplusplus)
#    define BC_EXTERN extern "C" __declspec(dllexport)
#   else
#    define BC_EXTERN extern __declspec(dllexport)
#   endif
#  else /* !defined(BC_BUILDING_CG) */
#   if defined(__cplusplus)
#    define BC_EXTERN extern "C" __declspec(dllimport)
#   else
#    define BC_EXTERN extern __declspec(dllimport)
#   endif
#  endif /* !defined(BC_BUILDING_BC) */
# else /* !defined(__WIN32__) */
#  if defined(__cplusplus)
#   define BC_EXTERN extern "C"
#  else
#   define BC_EXTERN extern
#  endif
# endif /* !defined(__WIN32__) */
#endif /* !defined(BC_EXTERN) */


#endif

#define DBLOGOPEN 1 //open database operation log.


#if DBLOGOPEN
#define DDDLog(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define DDDLog(FORMAT, ...)
#endif

#if DBLOGOPEN
#define LogDB DDDLog
#else
#define LogDB
#endif



#pragma mark ---- File  functions
#define PATH_OF_APP_HOME    NSHomeDirectory()
#define PATH_OF_TEMP        NSTemporaryDirectory()
#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define PATH_OF_LIBRARY_SUPPORT    [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#endif
