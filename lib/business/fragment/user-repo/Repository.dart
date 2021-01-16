import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:gitters/application.dart';
import 'package:gitters/business/widgets/avatar.dart';
import 'package:gitters/business/widgets/pages/error.dart';
import 'package:gitters/framework/global/constants/language/Localizations.dart';
import 'package:gitters/framework/global/provider/BaseModel.dart';
import 'package:provider/provider.dart';

class UserRepositoryHome extends StatefulWidget {
  RepositorySlug slug;

  UserRepositoryHome(this.slug, {Key key}) : super(key: key);

  @override
  _UserRepositoryHomeState createState() => _UserRepositoryHomeState();
}

class _UserRepositoryHomeState extends State<UserRepositoryHome> {
  GitHubFile readMe = GitHubFile();

  Future getRepositoryInfo(RepositorySlug slug) async {
    return Future.wait([
      gitHubClient.repositories.getRepository(slug),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(GittersLocalizations.of(context).Repository.toString()),
      ),
      body: FutureBuilder(
          future: getRepositoryInfo(widget.slug),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.active ||
                snapshot.connectionState == ConnectionState.waiting) {
              return new Center(
                child: new CircularProgressIndicator(),
              );
            }

            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text("目前不支持此类仓库的读取");
              } else if (snapshot.hasData) {
                Repository repo = snapshot.data[0];
                return buildRepoHome(repo);
              }
            }
            //请求未完成时弹出loading
            return CircularProgressIndicator();
          }),
    );
  }

  Widget buildRepoHome(Repository repository) {
    return RefreshIndicator(
      onRefresh: () {
        setState(() {});
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Row(
                      children: [
                        GitterAvatar(repository.owner.avatarUrl,
                            isClipRect: true, width: 48.0, height: 36.0),
                        buildPaddingInHV(3, 0),
                        Text(
                          repository.owner.login ?? '',
                          style: TextStyle(
                              fontSize: 24.0, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      children: [
                        Text('➤',
                            style: TextStyle(
                                color: context
                                    .read<BaseModel>()
                                    .themeData
                                    .primaryColor)),
                        buildPaddingInHV(3, 0),
                        Text(
                          repository.language ?? '',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              repository.fullName ?? '',
              style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w800),
            ),
            buildPaddingInHV(0, 6.0),
            Text(
              repository.description ?? '暂无描述...',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
            buildPaddingInHV(0, 6.0),
            buildKVRichText(context, "克隆 Url: ", repository.cloneUrl),
            buildDivider(context),
            buildKVRichText(context, '仓库关注人数: ',
                repository.stargazersCount.toString() ?? ''),
            buildPaddingInHV(0, 6),
            buildKVRichText(context, '仓库订阅人数: ',
                repository.subscribersCount.toString() ?? ''),
            buildPaddingInHV(0, 6),
            buildKVRichText(
                context, '仓库复制人数: ', repository.forksCount.toString() ?? ''),
            buildDivider(context),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildActionButton(context, Icons.star, "点击星标", () {}),
                  buildActionButton(
                      context, Icons.remove_red_eye, "点击关注", () {}),
                ],
              ),
            ),
            buildDivider(context),
            buildKVRichText(context, '目前的分支: ', repository.defaultBranch ?? ''),
            buildPaddingInHV(0, 6.0),
            buildKVRichText(context, '浏览代码: ', repository.name ?? ''),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
              child: Text(readMe.content ?? ''),
            ),
          ],
        ),
      ),
    );
  }
}

Text buildKVRichText(BuildContext context, String title, String content) {
  return Text.rich(TextSpan(children: [
    TextSpan(
        text: title,
        style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: context.read<BaseModel>().themeData.primaryColor)),
    TextSpan(
        text: content,
        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700)),
  ]));
}

Padding buildPaddingInHV(double h, double v) {
  return Padding(padding: EdgeInsets.symmetric(horizontal: h, vertical: v));
}

Widget buildDivider(BuildContext context) {
  return Container(
    height: 2,
    color: context.read<BaseModel>().themeData.primaryColor,
    margin: EdgeInsets.symmetric(vertical: 16.0),
  );
}

Widget buildActionButton(
    BuildContext context, IconData iconData, String content, Function onClick) {
  return FlatButton(
    color: context.read<BaseModel>().themeData.backgroundColor,
    clipBehavior: Clip.hardEdge,
    onPressed: onClick,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [Icon(iconData), Text(content)],
    ),
  );
}