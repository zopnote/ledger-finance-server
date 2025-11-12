import 'dart:io';

import 'package:ledger_finance_server_scripts/go_steps.dart';
import 'package:path/path.dart' as path;
import 'package:stepflow/cli.dart';
import 'package:stepflow/common.dart';

Future<void> main(List<String> args) async {
  print("Starting development build...\n");
  await runWorkflow(
    RunDevelopmentWorkflow(
      projectRoot: path
          .join(path.dirname(Platform.script.path), "../../")
          .substring(Platform.isWindows ? 1 : 0),
    ),
    (response) {
      if (response.level.value >= Level.error.value) {
        stderr.writeln(response.message);
      } else if (response.level.value >= Level.status.value) {
        stdout.writeln(response.message);
      }
    },
  );
}

final class BuildMainGo extends ConfigureStep {
  BuildMainGo({required this.projectRoot, required this.outputFile});
  final String projectRoot;
  final String outputFile;
  @override
  Step configure() {
    return Conditional(
      condition: () {
        final Iterable<String> files = Directory(
          projectRoot,
        ).listSync().where((e) => e is File).map((e) => path.basename(e.path));
        return files.contains("main.go");
      }(),
      child: GoBuild(
        projectDirectory: projectRoot,
        outputFile: outputFile,
        buildMode: GoBuildMode.debug,
      ),
    );
  }
}

final class RunDevelopmentWorkflow extends ConfigureStep {
  RunDevelopmentWorkflow({required this.projectRoot});
  final String projectRoot;
  @override
  Step configure() {
    final String buildDirectory = path.join(projectRoot, "build", "dev");
    return Chain(
      steps: [
        BuildMainGo(
          projectRoot: projectRoot,
          outputFile: path.join(
            buildDirectory,
            "ledge-fs${Platform.isWindows ? ".exe" : ""}",
          ),
        ),
        BuildMainGo(
          projectRoot: path.join(projectRoot, "server"),
          outputFile: path.join(
            buildDirectory,
            "server${Platform.isWindows ? ".exe" : ""}",
          ),
        ),
        Install(
          name: "Install resources",
          directories: ["assets"],
          installPath: buildDirectory,
          binariesPath: projectRoot,
        ),
        Runnable((context) {
          context.send(Response("Start application...\n", Level.status));
        }, name: "Send message"),
        Shell(
          name: "Execute client application",
          program: path.join(
            buildDirectory,
            "ledge-fs${Platform.isWindows ? ".exe" : ""}",
          ),
          arguments: [],
          onStdout: (context, chars) {
            context.send(Response(String.fromCharCodes(chars), Level.status));
          },
          onStderr: (context, chars) {
            context.send(Response(String.fromCharCodes(chars), Level.error));
          },
        ),
      ],
    );
  }
}
