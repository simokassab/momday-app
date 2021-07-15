//import 'package:permission_handler/permission_handler.dart';
//
//class AppPermissions{
//
//  /* check if permission is allow */
//  Future<Map<PermissionGroup, PermissionStatus>> getPermissionStatuses(List<PermissionGroup> requiredPermissions) async {
//    return await PermissionHandler().requestPermissions(requiredPermissions);
//  }
//
//  /* request permission */
//  Future<List<PermissionStatus>> requestPermissions(List<PermissionGroup> requiredPermissions) async {
//
//    List<PermissionStatus> permissionStatuses = [];
//    for(PermissionGroup requiredPermission in requiredPermissions){
//        PermissionStatus permissionStatus = await PermissionHandler().checkPermissionStatus(requiredPermission);
//        permissionStatuses.add(permissionStatus);
//      }
//
//      return permissionStatuses;
//  }
//
//  /* check permissions status and request if not granted yet */
//  Future<Map<PermissionGroup, PermissionStatus>> getOrRequestPermissions(requiredPermissions) async{
//
//    // check if permissions already granted
//
//    Map<PermissionGroup, PermissionStatus> currentPermissions = await this.getPermissionStatuses(requiredPermissions);
//
//
//    currentPermissions.forEach((permissionGroup,permissionStatus) async {
//
//      if(permissionStatus != PermissionStatus.granted){
//
//        // one of the permissions isn't granted so re-request and updated
//
//        await this.requestPermissions(requiredPermissions);
//        currentPermissions = await this.getPermissionStatuses(requiredPermissions);
//      }
//    });
//    return currentPermissions; // return the most recent permissions status
//  }
//}