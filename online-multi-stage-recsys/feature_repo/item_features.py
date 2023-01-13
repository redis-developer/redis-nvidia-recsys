
import os.path as osp

from datetime import timedelta
from feast.types import Int32
from feast import Entity, Field, FeatureView, ValueType
from feast.infra.offline_stores.file_source import FileSource


dir_path = osp.dirname(osp.abspath(__file__))
data_path = osp.join(dir_path, "data")

item_features = FileSource(
    path=f"{data_path}/item_features.parquet",
    timestamp_field="datetime",
    created_timestamp_column="created",
)

item = Entity(name="item_id", value_type=ValueType.INT32, description="item id")

item_features_view = FeatureView(
    name="item_features",
    entities=[item],
    ttl=timedelta(days=365),
    schema=[
        Field(name="item_category", dtype=Int32),
        Field(name="item_shop", dtype=Int32),
        Field(name="item_brand", dtype=Int32),
        Field(name="item_id_raw", dtype=Int32),
    ],
    online=True,
    source=item_features,
)
