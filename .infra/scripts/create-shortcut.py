#!/usr/bin/env python3
"""生成 iOS 快捷指令「存入知识库」的 .shortcut 文件"""

import plistlib
import subprocess
import os

def make_uuid():
    import uuid
    return str(uuid.uuid4()).upper()

def create_shortcut():
    # 目标路径
    inbox_path = "/文稿/ClaudeCode/inbox"

    actions = []

    # Action 0: 接收输入
    # (隐式，通过 WFWorkflowInputContentItemClasses 配置)

    # Action 1: 获取快捷指令输入的类型
    actions.append({
        "WFWorkflowActionIdentifier": "is.workflow.actions.getitemtype",
        "WFWorkflowActionParameters": {
            "WFInput": {
                "Value": {
                    "Type": "ActionOutput",
                    "OutputName": "Shortcut Input",
                    "OutputUUID": "SHORTCUT-INPUT-UUID"
                },
                "WFSerializationType": "WFTextTokenAttachment"
            }
        }
    })

    # Action 2: 获取当前日期
    actions.append({
        "WFWorkflowActionIdentifier": "is.workflow.actions.date",
        "WFWorkflowActionParameters": {
            "WFDateActionMode": "Current Date"
        }
    })

    # Action 3: 格式化日期为文件名
    date_uuid = make_uuid()
    actions.append({
        "WFWorkflowActionIdentifier": "is.workflow.actions.format.date",
        "WFWorkflowActionParameters": {
            "WFDateFormatStyle": "Custom",
            "WFDateFormat": "yyyy-MM-dd-HHmmss",
            "UUID": date_uuid
        }
    })

    # Action 4: 格式化日期为 YAML date
    yaml_date_uuid = make_uuid()
    actions.append({
        "WFWorkflowActionIdentifier": "is.workflow.actions.format.date",
        "WFWorkflowActionParameters": {
            "WFDateFormatStyle": "Custom",
            "WFDateFormat": "yyyy-MM-dd",
            "UUID": yaml_date_uuid
        }
    })

    # Action 5: If - 判断类型是否为 URL
    if_uuid = make_uuid()
    actions.append({
        "WFWorkflowActionIdentifier": "is.workflow.actions.conditional",
        "WFWorkflowActionParameters": {
            "GroupingIdentifier": if_uuid,
            "WFControlFlowMode": 0,  # Start of If
            "WFCondition": 4,  # is
            "WFConditionalActionString": "URL",
            "WFInput": {
                "Type": "Variable",
                "Variable": {
                    "Value": {
                        "Type": "ActionOutput",
                        "OutputName": "Type",
                        "OutputUUID": "TYPE-UUID"
                    },
                    "WFSerializationType": "WFTextTokenAttachment"
                }
            }
        }
    })

    # Action 6 (inside If/URL): 创建 markdown 文本
    text_uuid = make_uuid()
    actions.append({
        "WFWorkflowActionIdentifier": "is.workflow.actions.gettext",
        "WFWorkflowActionParameters": {
            "WFTextActionText": {
                "Value": {
                    "string": "---\ndate: ${yaml_date}\ntype: inbox\nsource: ${input}\n---\n\n# 待处理\n\n${input}",
                    "attachmentsByRange": {}
                },
                "WFSerializationType": "WFTextTokenString"
            },
            "UUID": text_uuid
        }
    })

    # Action 7 (inside If/URL): 保存 md 文件
    actions.append({
        "WFWorkflowActionIdentifier": "is.workflow.actions.documentpicker.save",
        "WFWorkflowActionParameters": {
            "WFFileDestinationPath": inbox_path,
            "WFFileName": {
                "Value": {
                    "string": "${filename}.md",
                    "attachmentsByRange": {}
                },
                "WFSerializationType": "WFTextTokenString"
            },
            "WFSaveFileOverwrite": False,
            "WFAskWhereToSave": False
        }
    })

    # Action 8: Otherwise (图片/文字)
    actions.append({
        "WFWorkflowActionIdentifier": "is.workflow.actions.conditional",
        "WFWorkflowActionParameters": {
            "GroupingIdentifier": if_uuid,
            "WFControlFlowMode": 1  # Otherwise
        }
    })

    # Action 9 (inside Otherwise): 保存文件（原始格式）
    actions.append({
        "WFWorkflowActionIdentifier": "is.workflow.actions.documentpicker.save",
        "WFWorkflowActionParameters": {
            "WFFileDestinationPath": inbox_path,
            "WFAskWhereToSave": False,
            "WFSaveFileOverwrite": False
        }
    })

    # Action 10: End If
    actions.append({
        "WFWorkflowActionIdentifier": "is.workflow.actions.conditional",
        "WFWorkflowActionParameters": {
            "GroupingIdentifier": if_uuid,
            "WFControlFlowMode": 2  # End If
        }
    })

    # Action 11: 显示通知
    actions.append({
        "WFWorkflowActionIdentifier": "is.workflow.actions.notification",
        "WFWorkflowActionParameters": {
            "WFNotificationActionBody": "已存入知识库 inbox",
            "WFNotificationActionTitle": "存入知识库"
        }
    })

    # 构建完整 shortcut plist
    shortcut = {
        "WFWorkflowMinimumClientVersion": 900,
        "WFWorkflowMinimumClientVersionString": "900",
        "WFWorkflowActions": actions,
        "WFWorkflowInputContentItemClasses": [
            "WFURLContentItem",
            "WFImageContentItem",
            "WFStringContentItem",
            "WFRichTextContentItem",
            "WFSafariWebPageContentItem",
            "WFAppStoreAppContentItem"
        ],
        "WFWorkflowTypes": ["NCWidget", "WatchKit"],
        "WFWorkflowHasShortcutInputVariables": True,
        "WFWorkflowIcon": {
            "WFWorkflowIconStartColor": 463140863,  # 蓝色
            "WFWorkflowIconGlyphNumber": 59761  # 书签图标
        },
        "WFWorkflowClientVersion": "2302.0.4",
        "WFWorkflowHasOutputFallback": False,
        "WFWorkflowName": "存入知识库"
    }

    return shortcut

def main():
    shortcut = create_shortcut()

    # 保存为 unsigned plist
    unsigned_path = "/tmp/save-to-kb-unsigned.shortcut"
    signed_path = os.path.expanduser("~/Desktop/存入知识库.shortcut")

    with open(unsigned_path, 'wb') as f:
        plistlib.dump(shortcut, f, fmt=plistlib.FMT_BINARY)

    # 用 shortcuts CLI 签名
    try:
        result = subprocess.run(
            ["shortcuts", "sign", "-i", unsigned_path, "-o", signed_path, "-m", "anyone"],
            capture_output=True, text=True
        )
        if result.returncode == 0:
            print(f"快捷指令已生成并签名: {signed_path}")
            print("双击此文件即可导入到快捷指令 App")
        else:
            print(f"签名失败: {result.stderr}")
            # 尝试直接导入未签名版本
            import shutil
            shutil.copy(unsigned_path, signed_path)
            print(f"已保存未签名版本到: {signed_path}")
    except Exception as e:
        print(f"错误: {e}")
        import shutil
        shutil.copy(unsigned_path, signed_path)
        print(f"已保存到: {signed_path}")

if __name__ == "__main__":
    main()
