import { BaseConfig } from "https://deno.land/x/ddc_vim@v4.0.4/types.ts";
import { fn } from "https://deno.land/x/ddc_vim@v4.0.4/deps.ts";
import { ConfigArguments } from "https://deno.land/x/ddc_vim@v4.0.4/base/config.ts";

export class Config extends BaseConfig {
	override async config(args: ConfigArguments): Promise<void> {
		args.contextBuilder.patchGlobal({
			ui: "pum",
			sources: [
				"copilot",
				"lsp",
				"around",
				"vsnip",
				"file",
				"skkeleton",
			],
			sourceOptions: {
				"copilot": {
					mark: "[copilot]",
					matchers: [],
					minAutoCompleteLength: 0,
					isVolatile: true,
				},

				"lsp": {
					dup: "keep",
					mark: "[lsp]",
					forceCompletionPattern:
						"\\.\\w*|:\\w*|->\\w*",
				},
				"skkeleton": {
					mark: "SKK",
					matchers: [],
					sorters: [],
					isVolatile: true,
				},

				vsnip: {
					mark: "[vsnip]",
				},

				_: {
					matchers: ["matcher_fuzzy"],
					sorters: ["sorter_fuzzy"],
					converters: ["converter_fuzzy"],
					keywordPattern: "\\k+",
				},
				around: { mark: "[around]" },
				file: {
					mark: "[file]",
					isVolatile: true,
					forceCompletionPattern: `\S/\S*`,
				},
			},
			sourceParams: {
				lsp: {
					enableResolveItem: true,
					enableAdditionalTextEdit: true,
					sorters: ["sorter_lsp-kind"],
					kindLabels: { "Class": "c" },
                                        bufnr: '%',
				},
			},
			postFilters: ["sorter_head"],
		});
	}
}
