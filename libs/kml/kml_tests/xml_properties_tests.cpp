#include "testing/testing.hpp"

#include "kml/serdes.hpp"

#include "coding/reader.hpp"
#include "coding/writer.hpp"

namespace xml_properties_tests
{
UNIT_TEST(Kml_PropertyKeysSurviveSerialization)
{
  kml::Properties const properties = {
      {"plain", "value"},        {"survey&notes", "ampersand"},         {"\"<tag>'", "quotes and brackets"},
      {"Мітка 地圖", "Unicode"}, {"tab\tline\nreturn\r", "whitespace"}, {"&amp;", "literal entity"}};
  kml::FileData data;
  data.m_categoryData.m_properties = properties;
  auto & bookmark = data.m_bookmarksData.emplace_back();
  bookmark.m_point = {0, 0};
  bookmark.m_properties = properties;
  auto & track = data.m_tracksData.emplace_back();
  track.m_layers.push_back(kml::KmlParser::GetDefaultTrackLayer());
  track.m_geometry.AddLine({{{0, 0}, 0}, {{1, 1}, 0}});
  track.m_geometry.AddTimestamps({});
  track.m_properties = properties;
  auto & area = data.m_areasData.emplace_back();
  area.m_polygons.push_back({{{{0, 0}, {}}, {{0, 2}, {}}, {{2, 0}, {}}}, {}});
  area.m_properties = properties;

  std::string text;
  MemWriter writer(text);
  kml::KmlWriter(writer).Write(data);
  kml::FileData loaded;
  kml::DeserializerKml(loaded).Deserialize(MemReader(text.data(), text.size()));
  TEST_EQUAL(loaded.m_bookmarksData.size(), 1, ());
  TEST_EQUAL(loaded.m_tracksData.size(), 1, ());
  TEST_EQUAL(loaded.m_areasData.size(), 1, ());
  TEST_EQUAL(loaded.m_categoryData.m_properties, properties, ());
  TEST_EQUAL(loaded.m_bookmarksData.front().m_properties, properties, ());
  TEST_EQUAL(loaded.m_tracksData.front().m_properties, properties, ());
  TEST_EQUAL(loaded.m_areasData.front().m_properties, properties, ());
}
}  // namespace xml_properties_tests
