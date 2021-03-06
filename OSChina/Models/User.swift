/**
 * Copyright (C) 2015 JianyingLi
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import ObjectMapper
import Ono
import SwiftyJSON

class User: Mappable {
    var uid: Int?               // 用户id
    var name: String?           // 用户名称
    var ident: String?          // 用户Ident
    var gender: Int?            // 性别：1-男，2-女
    var relation: Int?          // 关注情况：1-已关注（对方未关注我）2-相互关注 3-未关注
    var province: String?       // 省份
    var city: String!           // 城市
//    var platforms: [String]?    // 开发平台
//    var expertise: [String]?    // 专长领域
    var joinTime: String?       // 加入时间
    var lastLoginTime: String?  // 最近登录时间
    var portrait: String?       // 头像
    var fans: Int = 0           // 粉丝数
    var favoritecount: Int = 0  // 收藏数
    var followers: Int = 0      // 关注数
    var score: Int = 0          // 积分
    
    init() { }

    required init?(_ map: Map){
    }

    // Mappable
    func mapping(map: Map) {
        uid             <- map["uid"]
        name            <- map["name"]
        ident           <- map["ident"]
        gender          <- map["gender"]
        relation        <- map["relation"]
        province        <- map["province"]
        city            <- map["city"]
//        platforms       <- map["platforms"]
//        expertise       <- map["expertise"]
        joinTime        <- map["joinTime"]
        lastLoginTime   <- map["lastLoginTime"]
        portrait        <- map["portrait"]
        fans            <- map["fans"]
        favoritecount   <- map["favoritecount"]
        followers       <- map["followers"]
        score           <- map["score"]
    }
    
    static func parse(element: ONOXMLElement) -> User {
        let parser: XmlParser = XmlParser(element: element)
        let data: User = User()

        data.uid            = parser.integerValue("uid")
        data.name           = parser.stringValue("name")
        data.ident          = parser.stringValue("ident")
        data.gender         = parser.integerValue("gender")
        data.relation       = parser.integerValue("relation")
        data.province       = parser.stringValue("province")
        data.city           = parser.stringValue("city")
//        data.platforms      = element.firstChildWithTag("platforms").stringValue()
//        data.expertise      = element.firstChildWithTag("expertise").stringValue()
        data.joinTime       = parser.stringValue("joinTime")
        data.lastLoginTime  = parser.stringValue("lastLoginTime")
        data.portrait       = parser.stringValue("portrait")
        data.fans           = parser.integerValue("fans")
        data.favoritecount  = parser.integerValue("favoritecount")
        data.followers      = parser.integerValue("followers")
        data.score          = parser.integerValue("score")
        
        return data
    }
    
    static func current() -> User? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let jsonString = userDefaults.stringForKey("__current_user")
        if (jsonString != nil && jsonString != "") {
            let user: User? = Mapper<User>().map(jsonString!)
            return user
        }
        return nil
    }
    
    static func current(user: User?) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let jsonString = user == nil ? "" : Mapper<User>().toJSONString(user!, prettyPrint: false)
        userDefaults.setValue(jsonString, forKey: "__current_user")
    }
    
    static func isLogged() -> Bool {
        let user: User? = current()
        if (user != nil) {
            return true
        }
        return false;
    }
}
