import { BaseConfig } from "https://deno.land/x/ddu_vim@v4.0.0/types.ts";
import { ConfigArguments } from "https://deno.land/x/ddu_vim@v4.0.0/base/config.ts";

export class Config extends BaseConfig {
        override async config(args: ConfigArguments): Promise<void> {
                args.contextBuilder.patchGlobal({
                        ui: "filer",
                        uiParams: {
                                filer: {
                                        split: "floating",
                                        floatingBorder: "rounded",
                                        winWidth: "float2nr(&columns * 0.45)",
                                        winHeight: "float2nr(&lines * 0.8)",
                                        winRow: "float2nr(&lines * 0.1)",
                                        winCol: "float2nr((&columns - &columns * 0.45) / 2)",
                                },
                                ff: {
                                        autoAction: { name: "preview" },
                                        previewFloating: true,
                                        // previewSplit: "vertical",
                                        previewWidth:
                                                "float2nr(&columns * 0.4)",
                                        previewHeight: "float2nr(&lines * 0.8)",
                                        previewCol:
                                                "float2nr(&columns * 0.05 + &columns * 0.45 + 2)",
                                        previewRow: "float2nr(&lines * 0.92)",
                                        previewFloatingBorder: "rounded",
                                        split: "floating",
                                        floatingBorder: "rounded",
                                        winWidth: "float2nr(&columns * 0.45)",
                                        winHeight: "float2nr(&lines * 0.8)",
                                        winRow: "float2nr(&lines * 0.1)",
                                        winCol: "float2nr(&columns * 0.05)",
                                        prompt: "> ",
                                },
                        },
                        sourceOptions: {
                                _: {
                                        ignoreCase: true,
                                },
                                file_rec: {
                                        converters: [
                                                "converter_devicon",
                                        ],
                                        matchers: ["matcher_substring"],
                                },
                                mr: {
                                        converters: [
                                                "converter_devicon",
                                        ],
                                        matchers: ["matcher_substring"],
                                },
                                file: {
                                        columns: ["icon_filename"],
                                },
                        },
                        kindOptions: {
                                _: {
                                        defaultAction: "open",
                                },
                        },
                });

                args.contextBuilder.patchLocal("filer", {
                        sources: [
                                {
                                        name: "file",
                                },
                        ],
                });

                args.contextBuilder.patchLocal("ff", {
                        ui: "ff",
                        sources: [
                                {
                                        name: "file_rec",
                                },
                        ],
                });

                args.contextBuilder.patchLocal("ff-mr", {
                        ui: "ff",
                        sources: [
                                {
                                        name: "mr",
                                },
                        ],
                });

                args.contextBuilder.patchLocal("ff-buffer", {
                        ui: "ff",
                        sources: [
                                {
                                        name: "buffer",
                                },
                        ],
                });

                args.contextBuilder.patchLocal("ff-git_status", {
                        ui: "ff",
                        sources: [
                                {
                                        name: "git_status",
                                },
                        ],
                });
        }
}
