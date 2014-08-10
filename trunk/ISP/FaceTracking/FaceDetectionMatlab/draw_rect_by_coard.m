function draw_rect_by_coard(left, right, top, bottom)

hold on, line([left left],[top bottom]);
hold on, line([right right],[top bottom]);
hold on, line([right left],[top top]);
hold on, line([right left],[bottom bottom]);
axis([0 320 0 240]);, grid on,

return;