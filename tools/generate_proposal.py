from __future__ import annotations

from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    KeepTogether,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "docs" / "MoonSARIF-初审申报书.pdf"

FONT_REGULAR = Path(r"C:\Windows\Fonts\Deng.ttf")
FONT_BOLD = Path(r"C:\Windows\Fonts\Dengb.ttf")


def register_fonts() -> None:
    pdfmetrics.registerFont(TTFont("Deng", str(FONT_REGULAR)))
    pdfmetrics.registerFont(TTFont("Deng-Bold", str(FONT_BOLD)))


def section(title: str, body: str, styles: dict[str, ParagraphStyle]):
    return KeepTogether(
        [
            Paragraph(title, styles["section"]),
            Paragraph(body, styles["body"]),
            Spacer(1, 2.2 * mm),
        ]
    )


def add_page_decor(canvas, doc) -> None:
    width, height = A4
    canvas.saveState()
    canvas.setFillColor(colors.HexColor("#155EEF"))
    canvas.rect(0, height - 8 * mm, width, 8 * mm, stroke=0, fill=1)
    canvas.setFillColor(colors.HexColor("#E8F0FF"))
    canvas.rect(0, 0, width, 4 * mm, stroke=0, fill=1)
    canvas.setFont("Deng", 7)
    canvas.setFillColor(colors.HexColor("#667085"))
    canvas.drawString(14 * mm, 6.2 * mm, "MoonSARIF · MoonBit 开源生态基础库与开发工具")
    canvas.drawRightString(width - 14 * mm, 6.2 * mm, "2026-08-23")
    canvas.restoreState()


def build_pdf() -> None:
    register_fonts()
    styles = {
        "title": ParagraphStyle(
            "Title",
            fontName="Deng-Bold",
            fontSize=20,
            leading=24,
            textColor=colors.HexColor("#101828"),
            alignment=TA_CENTER,
            spaceAfter=1.5 * mm,
        ),
        "subtitle": ParagraphStyle(
            "Subtitle",
            fontName="Deng",
            fontSize=8.6,
            leading=11,
            textColor=colors.HexColor("#667085"),
            alignment=TA_CENTER,
            spaceAfter=2.6 * mm,
        ),
        "section": ParagraphStyle(
            "Section",
            fontName="Deng-Bold",
            fontSize=10.6,
            leading=13,
            textColor=colors.HexColor("#155EEF"),
            spaceAfter=0.6 * mm,
        ),
        "body": ParagraphStyle(
            "Body",
            fontName="Deng",
            fontSize=9,
            leading=12.3,
            textColor=colors.HexColor("#344054"),
            alignment=TA_LEFT,
        ),
        "table_key": ParagraphStyle(
            "TableKey",
            fontName="Deng-Bold",
            fontSize=8.3,
            leading=10.8,
            textColor=colors.HexColor("#344054"),
        ),
        "table_value": ParagraphStyle(
            "TableValue",
            fontName="Deng",
            fontSize=8.3,
            leading=10.8,
            textColor=colors.HexColor("#344054"),
        ),
        "callout": ParagraphStyle(
            "Callout",
            fontName="Deng",
            fontSize=8.5,
            leading=11,
            textColor=colors.HexColor("#1849A9"),
        ),
    }

    doc = SimpleDocTemplate(
        str(OUTPUT),
        pagesize=A4,
        leftMargin=13 * mm,
        rightMargin=13 * mm,
        topMargin=12 * mm,
        bottomMargin=11 * mm,
        title="MoonSARIF 初审项目申报书",
        author="Noverberrain",
        subject="MoonBit 开源生态项目申报材料",
    )

    story = [
        Paragraph("MoonSARIF 初审项目申报书", styles["title"]),
        Paragraph(
            "纯 MoonBit 的 SARIF 2.1.0 解析、校验、合并与报告工具链",
            styles["subtitle"],
        ),
    ]

    info = [
        [
            Paragraph("项目方向", styles["table_key"]),
            Paragraph("MoonBit 开源生态基础库与开发工具", styles["table_value"]),
            Paragraph("许可证", styles["table_key"]),
            Paragraph("Apache-2.0", styles["table_value"]),
        ],
        [
            Paragraph("项目性质", styles["table_key"]),
            Paragraph("原创实现，不移植第三方源码", styles["table_value"]),
            Paragraph("当前基础", styles["table_key"]),
            Paragraph("0.3.0 验收候选版 · 20 个库级测试", styles["table_value"]),
        ],
        [
            Paragraph("GitHub", styles["table_key"]),
            Paragraph(
                "github.com/Noverberrain/MoonSARIF",
                styles["table_value"],
            ),
            Paragraph("GitLink", styles["table_key"]),
            Paragraph(
                "gitlink.org.cn/Wyc060514/moonsarif",
                styles["table_value"],
            ),
        ],
        [
            Paragraph("Mooncakes", styles["table_key"]),
            Paragraph("mooncakes.io/docs/Noverberrain/moonsarif · 0.3.0", styles["table_value"]),
            Paragraph("发布状态", styles["table_key"]),
            Paragraph("已发布", styles["table_value"]),
        ],
    ]
    table = Table(
        info,
        colWidths=[18 * mm, 70 * mm, 17 * mm, 70 * mm],
        hAlign="CENTER",
    )
    table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor("#F5F8FF")),
                ("BOX", (0, 0), (-1, -1), 0.6, colors.HexColor("#B2CCFF")),
                ("INNERGRID", (0, 0), (-1, -1), 0.35, colors.HexColor("#D1E0FF")),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("LEFTPADDING", (0, 0), (-1, -1), 4),
                ("RIGHTPADDING", (0, 0), (-1, -1), 4),
                ("TOPPADDING", (0, 0), (-1, -1), 3.2),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 3.2),
            ]
        )
    )
    story.extend([table, Spacer(1, 2.3 * mm)])

    story.append(
        section(
            "一、项目简介与应用场景",
            "MoonSARIF 面向静态分析器、代码扫描平台、CI/CD 系统和 AI 编程 Agent，帮助 MoonBit 工具生成标准化 SARIF 2.1.0 扫描结果，并在上传 GitHub Code Scanning 等平台前完成兼容性检查、结果筛选、去重和报告生成。",
            styles,
        )
    )
    story.append(
        section(
            "二、生态价值与创新点",
            "选题调研未在 mooncakes.io 发现专门的 SARIF 工具包。项目将填补 MoonBit 静态分析结果交换基础设施空白；区别于通用 JSON 库，MoonSARIF 提供领域类型、语义校验、跨平台路径处理、稳定指纹、baseline 对比和 CI 报告能力，可成为其他 MoonBit 检查器与质量平台的公共底座。",
            styles,
        )
    )
    story.append(
        section(
            "三、核心功能与现有基础",
            "已完成核心类型模型、JSON 往返与 <b>$schema</b> 保留、结构/语义校验、严重等级统计、按 level/rule/path 筛选、路径归一化、多日志合并、确定性指纹、去重、baseline 比较、CI 门禁、baselineState 标注、GitHub Code Scanning 常见兼容性检查、relatedLocations/fingerprints/suppressions/fixes/properties 字段、Markdown/HTML 报告及文件型 CLI。20 个库级测试已在 wasm、wasm-gc、JavaScript、native 后端全部通过；CI 另覆盖 CLI 回归 smoke test、1000 条结果小型性能基准、格式、严格检查和公共接口一致性。",
            styles,
        )
    )
    story.append(
        section(
            "四、技术路线与实施计划",
            "采用“类型模型 → JSON 编解码 → 语义校验 → 统计/筛选/合并 → 指纹/去重/baseline → 报告渲染 → CLI 适配”分层架构。当前版本已完成核心闭环、CI baseline 门禁、GitHub 兼容性检查、可留档报告、CLI 回归测试和小型性能基准；后续根据验收反馈补充更多 SARIF 字段、平台兼容规则、流式处理和 Mooncakes 包维护。",
            styles,
        )
    )
    story.append(
        section(
            "五、预期交付成果",
            "本阶段交付可复用 MoonBit 包、文件型 CLI、Markdown/HTML 报告、baseline CI 门禁、GitHub Code Scanning 兼容性检查、常用 SARIF 结果字段、示例与 API/架构/兼容性文档、CLI 回归测试、小型性能基准、贡献与安全策略、跨后端测试与 CI、GitHub/GitLink 双仓库及申报书 Markdown/PDF。WebAssembly 在线查看器和流式大文件处理不列为本版本已完成承诺。",
            styles,
        )
    )
    story.append(
        section(
            "六、原创性、开源合规与 AI 使用说明",
            "项目依据公开的 OASIS SARIF 2.1.0 标准原创实现，不复制第三方实现源码；规范、测试数据与依赖来源将在仓库中注明并核对许可证。开发中使用 Codex 辅助需求整理、架构设计、实现、测试和文档，最终设计取舍、代码审核、提交及参赛责任由申报人承担。",
            styles,
        )
    )

    risk = Table(
        [
            [
                Paragraph("<b>风险与应对</b>", styles["callout"]),
                Paragraph(
                    "针对规范覆盖面、平台差异、指纹准确性及大文件性能风险，采用分阶段类型覆盖、官方/错误样例、跨后端回归、基准测试、流式处理预研和版本化 API 控制风险。",
                    styles["callout"],
                ),
            ]
        ],
        colWidths=[23 * mm, 152 * mm],
    )
    risk.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor("#EFF4FF")),
                ("BOX", (0, 0), (-1, -1), 0.5, colors.HexColor("#84ADFF")),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("LEFTPADDING", (0, 0), (-1, -1), 5),
                ("RIGHTPADDING", (0, 0), (-1, -1), 5),
                ("TOPPADDING", (0, 0), (-1, -1), 4),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
            ]
        )
    )
    story.append(risk)

    doc.build(story, onFirstPage=add_page_decor, onLaterPages=add_page_decor)


if __name__ == "__main__":
    build_pdf()
    print(OUTPUT)
