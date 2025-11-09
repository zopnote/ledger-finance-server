import 'dart:io';

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

final class RunDevelopmentWorkflow extends ConfigureStep {
  RunDevelopmentWorkflow({required this.projectRoot});
  final String projectRoot;
  @override
  Step configure() {
    final String buildDirectory = path.join(projectRoot, "build", "dev");
    return Chain(
      steps: [
        Conditional(
          condition: () {
            final Iterable<String> files = Directory(projectRoot)
                .listSync()
                .where((e) => e is File)
                .map((e) => path.basename(e.path));
            return files.contains("main.go");
          }(),
          child: GoBuild(
            projectDirectory: projectRoot,
            outputFile: path.join(
              buildDirectory,
              "ledge-fs${Platform.isWindows ? ".exe" : ""}",
            ),
            buildMode: GoBuildMode.debug,
          ),
        ),
        Conditional(
          condition: () {
            final Iterable<String> files = Directory(path.join(projectRoot, "server"))
                .listSync()
                .where((e) => e is File)
                .map((e) => path.basename(e.path));
            return files.contains("main.go");
          }(),
          child: GoBuild(
            projectDirectory: path.join(projectRoot, "server"),
            outputFile: path.join(
              buildDirectory,
              "server${Platform.isWindows ? ".exe" : ""}",
            ),
            buildMode: GoBuildMode.debug,
          ),
        ),
        Install(
            name: "Install resources",
            directories: ["assets"],
            installPath: buildDirectory,
            binariesPath: projectRoot
        ),
        Runnable((context) {
          context.send(Response("Start application...\n", Level.status));
        }, name: "Send message"),
        Shell(
            name: "Execute client application",
            program: path.join(buildDirectory, "ledge-fs${Platform.isWindows ? ".exe": ""}"),
            arguments: [],
          onStdout: (context, chars) {
              context.send(Response(String.fromCharCodes(chars), Level.status));
          },
          onStderr: (context, chars) {
              context.send(Response(String.fromCharCodes(chars), Level.error));
          }
        )
      ],
    );
  }
}

enum GoBuildMode { release, debug }

class GoBuild extends ConfigureStep {
  const GoBuild({
    required this.projectDirectory,
    required this.outputFile,
    required this.buildMode,
    this.goExecutable,
  });

  final String projectDirectory;
  final String outputFile;
  final GoBuildMode buildMode;
  final String? goExecutable;

  @override
  Step configure() {
    return Chain(
      steps: [
        Conditional(
          condition: goExecutable == null,
          child: Check(
            name: "Check for installed Go distribution",
            programs: ["go"],
            onFailure: (context, _) {
              context.pop("Go isn't installed on the system.");
            },
          ),
        ),
        Shell(
          name: "Compile Go source code",
          program: "go",
          arguments: () {
            List<String> arguments = ["build", "-o", outputFile];
            if (buildMode == GoBuildMode.release) {
              arguments += ["-ldflags", "-s", "-w"];
            }
            return arguments += ["."];
          }(),
          workingDirectory: projectDirectory,
          onStderr: (context, chars) {
            context.send(Response(String.fromCharCodes(chars), Level.critical));
          },
          onStdout: (context, chars) {
            context.send(Response(String.fromCharCodes(chars), Level.verbose));
          },
          runAsAdministrator: false,
          runInShell: false,
        ),
      ],
    );
  }
}