import 'package:stepflow/cli.dart';
import 'package:stepflow/common.dart';

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
          program: goExecutable ?? "go",
          arguments: () {
            List<String> arguments = ["build", "-o", outputFile];
            if (buildMode == GoBuildMode.release) {
              arguments += ["-ldflags", "-s", "-w", "-buildmode=exe"];
            }
            return arguments += ["."];
          }(),
          workingDirectory: projectDirectory,
          onStderr: (context, chars) {
            context.send(
                Response(
                    String.fromCharCodes(chars), Level.critical
                ));
          },
          onStdout: (context, chars) {
            context.send(
                Response(String.fromCharCodes(chars), Level.verbose
                ));
          },
          runAsAdministrator: false,
          runInShell: false,
        ),
      ],
    );
  }
}