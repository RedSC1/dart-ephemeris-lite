# 恒星与 TSC1

`parseTsc1Catalog(Uint8List)` / `Tsc1Catalog` 读取兼容 C++ 的 TSC1 v1 文件，保留头部、92 字节星记录与 16 字节别名记录格式。完整表和 lite 表使用同一解码器；不做新的亮度过滤或删别名。

- `catalog.getStar(index)`、`catalog.find(alias)` 与迭代器访问记录。ASCII 别名归一化与 C++ 一致，中文等非 ASCII 文本原样保留；哈希为 FNV-1a 64 位。
- Gaia ID 和别名哈希使用 BigInt，避免网页数字精度损失。目录复制输入字节并设为只读，输入缓冲后续改动不会破坏索引。越界、版本、字符串终止和索引排序会验证；UTF-8 在字符串解码时严格检查。
- `fixedStarIcrfState(catalog,key,jdTT)` 计算线性空间运动，包含自行、视差和径向速度。key 可以是别名、索引或目录记录。无视差时采用 1e9 AU 的方向载体，不代表实际距离。
- `fixedStarPosition` / `fixedStarState` 支持 `FixedStarOptions(frame, aberration, solarDeflection)`；默认日期真坐标、光行差和太阳引力偏折开启。速度差分包含观测者运动、修正和坐标变化，没有虚构的星历精度档位。
- JSON 中 Gaia ID 为十进制字符串，星表缺测的非有限数值为 null。所有向量和结果字段只读。

底层只依赖 Dart 核心库，不自动联网或读取文件。应用自行取得 TSC1 字节；Node/JS 独立星表包中的文件可直接复用。`example/fixed_stars.dart` 演示 Dart CLI 读取文件；网页可把下载字节交给相同解析器。

测试夹具为上游完整 lite 文件，2057 条记录、12242 条别名；包含亮星以及传统中国星官、十二星座线图补全和特殊方向记录，不是单独 V≤5 截断。夹具来源声明在 `test/fixtures/STARS_THIRD_PARTY_NOTICES.md`，不进入底层发布产物。

线性自行不是完整 N 体恒星轨道模型；大年代传播和缺测记录需要按数据本身的不确定性解释。
